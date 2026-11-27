import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { asset } from '@kit.AssetStoreKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';

const PREFIX = 'flutter.';
const SENSITIVE_KEYS: string[] = [
  'token', 'password', 'lakeToken', 'customCourseToken', 'tjupasswd', 'lafToken', 'gsessionid', 'garbled',
];
const NOT_FOUND = 24000002;
const ALREADY_EXISTS = 24000003;
const encoder = util.TextEncoder.create('utf-8');
const decoder = util.TextDecoder.create('utf-8');

function secretAlias(name: string): asset.AssetMap {
  const fields = new Map<asset.Tag, asset.Value>();
  fields.set(asset.Tag.ALIAS, encoder.encodeInto('wepeiyang.preference.' + name));
  return fields;
}

export async function readSecurePreference(name: string): Promise<string | undefined> {
  const query = secretAlias(name);
  query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);
  try {
    const records = await asset.query(query);
    return records.length ? decoder.decodeToString(records[0].get(asset.Tag.SECRET) as Uint8Array) : undefined;
  } catch (error) {
    if ((error as BusinessError).code !== NOT_FOUND) throw error;
    return undefined;
  }
}

export class PreferencesHandler implements MethodCallHandler {
  private readonly store: Promise<preferences.Preferences>;
  private readonly onClearAccount: (logout: boolean, hadPush: boolean) => Promise<void>;
  private readonly onCampusAccountChanged: () => Promise<void>;
  private pending: Promise<void> = Promise.resolve();

  constructor(context: common.UIAbilityContext, onClearAccount: (logout: boolean, hadPush: boolean) => Promise<void>,
    onCampusAccountChanged: () => Promise<void>) {
    this.store = preferences.getPreferences(context, 'wepeiyang_preferences');
    this.onClearAccount = onClearAccount;
    this.onCampusAccountChanged = onCampusAccountChanged;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.pending = this.pending.then(() => this.handle(call, result)).catch((error: BusinessError) => {
      result.error('PREFERENCES_ERROR', error.message, error.code);
    });
  }

  private async handle(call: MethodCall, result: MethodResult): Promise<void> {
    const store = await this.store;
    const key = call.argument('key') as string;
    switch (call.method) {
      case 'getAll': {
        const prefix = (call.argument('prefix') as string | null) ?? PREFIX;
        const allowList = call.argument('allowList') as string[] | null;
        const stored = await store.getAll();
        const values: Record<string, preferences.ValueType> = {};
        for (const candidate of Object.keys(stored)) {
          if (candidate.startsWith(prefix) && (!allowList || allowList.includes(candidate))) {
            values[candidate] = stored[candidate];
          }
        }
        for (const name of SENSITIVE_KEYS) {
          const fullKey = PREFIX + name;
          if (!fullKey.startsWith(prefix) || (allowList && !allowList.includes(fullKey))) continue;
          const secret = await readSecurePreference(name);
          if (secret !== undefined) values[fullKey] = secret;
        }
        result.success(values);
        break;
      }
      case 'set': {
        const value = call.argument('value') as preferences.ValueType;
        const changedCampusAccount = (key === PREFIX + 'userNumber' &&
          await store.get(key, '') !== value) || (key === PREFIX + 'login' && value === false);
        if (this.isSensitive(key)) {
          const secret = value as string;
          if (secret.length > 0) {
            await this.writeSecret(key, secret);
          } else {
            await this.remove(store, key);
            await store.flush();
          }
        } else {
          await store.put(key, value);
          await store.flush();
        }
        if (changedCampusAccount || (key === PREFIX + 'token' && value === '')) {
          await this.onCampusAccountChanged();
        }
        result.success(true);
        break;
      }
      case 'remove':
        await this.remove(store, key);
        await store.flush();
        if (key === PREFIX + 'bindtju') await this.onClearAccount(false, false);
        if (key === PREFIX + 'userNumber' || key === PREFIX + 'login' || key === PREFIX + 'token') {
          await this.onCampusAccountChanged();
        }
        result.success(true);
        break;
      case 'clear': {
        const prefix = call.argument('prefix') as string;
        const allowList = call.argument('allowList') as string[] | null;
        const logout = prefix === PREFIX && !allowList;
        const hadPush = logout && await store.get(PREFIX + 'can_push', false) === true;
        const values = await store.getAll();
        const keys = new Set<string>(Object.keys(values).concat(SENSITIVE_KEYS.map(name => PREFIX + name)));
        for (const candidate of keys) {
          if (candidate.startsWith(prefix) && (!allowList || allowList.includes(candidate))) {
            await this.remove(store, candidate);
          }
        }
        await store.flush();
        if (logout) {
          await this.onCampusAccountChanged();
          await this.onClearAccount(true, hadPush);
        }
        result.success(true);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  private isSensitive(key: string): boolean {
    return key.startsWith(PREFIX) && SENSITIVE_KEYS.includes(key.substring(PREFIX.length));
  }

  private alias(key: string): asset.AssetMap {
    return secretAlias(key.substring(PREFIX.length));
  }

  private async writeSecret(key: string, value: string): Promise<void> {
    const data = this.alias(key);
    const secret = new Map<asset.Tag, asset.Value>();
    secret.set(asset.Tag.SECRET, encoder.encodeInto(value));
    try {
      await asset.update(data, secret);
    } catch (error) {
      if ((error as BusinessError).code !== NOT_FOUND) throw error;
      const attributes = this.alias(key);
      attributes.set(asset.Tag.SECRET, encoder.encodeInto(value));
      attributes.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_FIRST_UNLOCKED);
      try {
        await asset.add(attributes);
      } catch (addError) {
        if ((addError as BusinessError).code !== ALREADY_EXISTS) throw addError;
        await asset.update(data, secret);
      }
    }
  }

  private async remove(store: preferences.Preferences, key: string): Promise<void> {
    if (this.isSensitive(key)) {
      try {
        await asset.remove(this.alias(key));
      } catch (error) {
        if ((error as BusinessError).code !== NOT_FOUND) throw error;
      }
    }
    if (await store.has(key)) await store.delete(key);
  }
}
