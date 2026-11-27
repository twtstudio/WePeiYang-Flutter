import { common } from '@kit.AbilityKit';
import { updateManager } from '@kit.AppGalleryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';

export class AppUpdateHandler implements MethodCallHandler {
  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      if (call.method === 'checkAppUpdate') {
        const version = await updateManager.checkAppUpdate(this.context);
        switch (version.updateAvailable) {
          case updateManager.UpdateAvailableCode.LATER_VERSION_EXIST:
            result.success(true);
            break;
          case updateManager.UpdateAvailableCode.LATER_VERSION_NOT_EXIST:
            result.success(false);
            break;
          default:
            result.error('UPDATE_UNAVAILABLE', 'AppGallery version information is unavailable', version.updateAvailable);
        }
      } else if (call.method === 'showAppUpdateDialog') {
        const status = await updateManager.showUpdateDialog(this.context);
        if (status === updateManager.ShowUpdateResultCode.SHOW_DIALOG_SUCCESS) {
          result.success(null);
        } else {
          result.error('UPDATE_DIALOG_FAILED', 'Unable to show the AppGallery update dialog', status);
        }
      } else {
        result.notImplemented();
      }
    } catch (error) {
      const err = error as BusinessError;
      result.error('UPDATE_FAILED', err.message, err.code);
    }
  }
}
