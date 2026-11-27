import { bundleManager, common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { batteryInfo, BusinessError } from '@kit.BasicServicesKit';
import { storageStatistics } from '@kit.CoreFileKit';
import deviceInfo from '@ohos.deviceInfo';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';

export class SystemHandler implements MethodCallHandler {
  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'getPaths': {
          const paths: Record<string, string> = { files: this.context.filesDir, cache: this.context.cacheDir };
          result.success(paths);
          break;
        }
        case 'getDeviceInfo':
          result.success(await this.getDeviceInfo());
          break;
        case 'getAll':
        case 'bundleVersion': {
          const info = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
          if (call.method === 'bundleVersion') {
            result.success(info.versionName);
            break;
          }
          const version: Record<string, string> = {
            appName: '微北洋', packageName: info.name, version: info.versionName, buildNumber: String(info.versionCode),
          };
          result.success(version);
          break;
        }
        case 'canLaunchUrl':
          result.success(this.canLaunch(call.argument('url') as string));
          break;
        case 'launchUrl':
          result.success(await this.launch(call.argument('url') as string, call.argument('appLinkingOnly') === true));
          break;
        default:
          result.notImplemented();
      }
    } catch (error) {
      const err = error as BusinessError;
      result.error('OHOS_SYSTEM_ERROR', err.message, err.code);
    }
  }

  private async getDeviceInfo(): Promise<Record<string, string | number | Record<string, number>>> {
    const device: Record<string, string | number | Record<string, number>> = {
      manufacturer: deviceInfo.manufacture,
      brand: deviceInfo.brand,
      model: deviceInfo.productModel,
      display: deviceInfo.displayVersion,
      versionRelease: deviceInfo.osFullName,
      sdkInt: deviceInfo.sdkApiVersion,
    };
    if (canIUse('SystemCapability.PowerManager.BatteryManager.Core')) {
      device['battery'] = { batteryPct: batteryInfo.batterySOC };
    }
    try {
      const screen = display.getDefaultDisplaySync();
      device['density'] = {
        densityDpi: screen.densityDPI,
        density: screen.densityPixels,
        scaledDensity: screen.scaledDensity,
        refreshRate: screen.refreshRate,
      };
    } catch (_) {
      // Display details may be unavailable before the window is created.
    }
    try {
      const [total, free] = await Promise.all([storageStatistics.getTotalSize(), storageStatistics.getFreeSize()]);
      const gigabyte = 1024 * 1024 * 1024;
      device['storage'] = { storageTotal: total / gigabyte, storageAvail: free / gigabyte };
    } catch (_) {
      // Keep the available diagnostics if the storage query fails.
    }
    return device;
  }

  private canLaunch(uri: string): boolean {
    return /^(https?:\/\/|mailto:|tel:|sms:|wpy:\/\/)/i.test(uri);
  }

  private async launch(uri: string, appLinkingOnly: boolean): Promise<boolean> {
    if (!this.canLaunch(uri)) return false;
    try {
      if (appLinkingOnly) {
        await this.context.openLink(uri, { appLinkingOnly: true });
      } else {
        await this.context.startAbility({ action: 'ohos.want.action.viewData', uri });
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
