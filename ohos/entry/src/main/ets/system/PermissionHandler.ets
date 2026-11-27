import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';

const MICROPHONE = 'ohos.permission.MICROPHONE';
let microphoneRequiresSettings = false;

export async function microphoneGranted(context: common.UIAbilityContext, request: boolean): Promise<boolean> {
  return await microphoneStatus(context, request) === 1;
}

async function microphoneStatus(context: common.UIAbilityContext, request: boolean): Promise<number> {
  const manager = abilityAccessCtrl.createAtManager();
  const granted = abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  if (manager.checkAccessTokenSync(context.applicationInfo.accessTokenId, MICROPHONE) === granted) {
    microphoneRequiresSettings = false;
    return 1;
  }
  if (request) {
    const outcome = await manager.requestPermissionsFromUser(context, [MICROPHONE]);
    const status = outcome.authResults[0];
    microphoneRequiresSettings = status === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED &&
      outcome.dialogShownResults?.[0] === false;
    if (status === granted) return 1;
  }
  return microphoneRequiresSettings ? 4 : 0;
}

export class PermissionHandler implements MethodCallHandler {
  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'checkPermissionStatus':
          result.success(await this.status(call.args as number, false));
          break;
        case 'requestPermissions': {
          const results = new Map<number, number>();
          for (const permission of call.args as number[]) {
            results.set(permission, await this.status(permission, true));
          }
          result.success(results);
          break;
        }
        case 'openAppSettings':
          await abilityAccessCtrl.createAtManager().requestPermissionOnSetting(this.context, [MICROPHONE]);
          result.success(true);
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      const err = error as BusinessError;
      result.error('PERMISSION_ERROR', err.message, err.code);
    }
  }

  private async status(permission: number, request: boolean): Promise<number> {
    if (permission === 7) {
      return await microphoneStatus(this.context, request);
    }
    return 0;
  }
}
