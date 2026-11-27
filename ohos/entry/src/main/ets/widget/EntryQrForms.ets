import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { url } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { readSecurePreference } from '../storage/PreferencesHandler';
import { fetchJsonText, isHttpsUrl, readServiceConfig } from '../system/WpyServiceConfig';

const MAX_VALIDITY_MS = 180000;
const FORM_ID = /^\d{1,32}$/;

interface EntryCode {
  code: string;
  expiresAt: number;
}

interface EntryQrBinding {
  status: string;
  code: string;
  expiresAt: number;
  canRefresh: boolean;
}

export class EntryQrForms {
  private readonly context: common.Context;
  private readonly directory: string;
  private readonly endpoint: string;
  private generation = 0;
  private pending: Promise<void> = Promise.resolve();

  constructor(context: common.Context) {
    this.context = context;
    this.directory = context.getApplicationContext().filesDir + '/entry_qr_forms';
    const endpoint = readServiceConfig(context).entryQrUrl ?? '';
    this.endpoint = isHttpsUrl(endpoint) && url.URL.parseURL(endpoint).origin === 'https://api.twt.edu.cn'
      ? endpoint : '';
  }

  register(id: string): boolean {
    if (!FORM_ID.test(id)) return false;
    if (!fileIo.accessSync(this.directory)) fileIo.mkdirSync(this.directory, true);
    const file = fileIo.openSync(this.directory + '/' + id, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
    fileIo.closeSync(file);
    return true;
  }

  unregister(id: string): void {
    if (this.exists(id)) fileIo.unlinkSync(this.directory + '/' + id);
  }

  binding(status: string = 'empty', value?: EntryCode): formBindingData.FormBindingData {
    const binding: EntryQrBinding = {
      status: status, code: value?.code ?? '', expiresAt: value?.expiresAt ?? 0, canRefresh: this.endpoint !== '',
    };
    return formBindingData.createFormBindingData(binding);
  }

  async refresh(id: string): Promise<void> {
    if (!this.endpoint || !this.exists(id)) return;
    const generation = this.generation;
    try {
      const account = await this.account();
      const token = account ? await readSecurePreference('token') : undefined;
      if (!token) {
        if (this.exists(id)) await formProvider.updateForm(id, this.binding('signed_out'));
        return;
      }
      if (!this.exists(id) || generation !== this.generation) return;
      await formProvider.updateForm(id, this.binding('loading'));
      const text = await fetchJsonText(this.endpoint, {
        'Accept': 'application/json', 'Authorization': 'Bearer ' + token,
      });
      const value = JSON.parse(text) as EntryCode;
      if (!this.valid(value)) throw new Error('Invalid campus entry code');
      const stillSignedIn = account === await this.account() && token === await readSecurePreference('token');
      if (stillSignedIn && this.exists(id) && generation === this.generation) {
        await formProvider.updateForm(id, this.binding('ready', value));
        if (token !== await readSecurePreference('token') && this.exists(id)) {
          await formProvider.updateForm(id, this.binding('empty'));
        }
      }
    } catch (_) {
      if (this.exists(id) && generation === this.generation) await formProvider.updateForm(id, this.binding('failed'));
    }
  }

  publish(account: string, code: string, expiresAt: number): Promise<void> {
    const generation = this.generation;
    return this.enqueue(async () => {
      const value: EntryCode = { code: code, expiresAt: expiresAt };
      if (this.valid(value) && account && account === await this.account() && generation === this.generation) {
        await this.updateAll(this.binding('ready', value));
      }
    });
  }

  clear(): Promise<void> {
    this.generation++;
    return this.enqueue(() => this.updateAll(this.binding('empty')));
  }

  private enqueue(action: () => Promise<void>): Promise<void> {
    const task = this.pending.then(action);
    this.pending = task.catch(() => {});
    return task;
  }

  private async account(): Promise<string> {
    const store = await preferences.getPreferences(this.context, 'wepeiyang_preferences');
    if (await store.get('flutter.login', false) !== true) return '';
    return await store.get('flutter.userNumber', '') as string;
  }

  private valid(value: EntryCode): boolean {
    const now = Date.now();
    return !!value && typeof value.code === 'string' && value.code.trim().length > 0 && value.code.length <= 512 &&
      Number.isSafeInteger(value.expiresAt) && value.expiresAt > now && value.expiresAt <= now + MAX_VALIDITY_MS;
  }

  private exists(id: string): boolean {
    return FORM_ID.test(id) && fileIo.accessSync(this.directory + '/' + id);
  }

  private async updateAll(data: formBindingData.FormBindingData): Promise<void> {
    if (!fileIo.accessSync(this.directory)) return;
    const ids = fileIo.listFileSync(this.directory).filter(id => FORM_ID.test(id));
    await Promise.all(ids.map(id => formProvider.updateForm(id, data).catch(() => {})));
  }
}
