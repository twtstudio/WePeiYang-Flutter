import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { init, onEventObject, onProfileSignIn, onProfileSignOff } from '@umeng/analytics';
import { isAnalyticsPrepared } from './EntryAbilityStage';

let analyticsStarted = false;

export class StatisticsHandler implements MethodCallHandler {
  private readonly pageStarts = new Map<string, number>();

  onMethodCall(call: MethodCall, result: MethodResult): void {
    try {
      if (call.method === 'initCommon') {
        if (isAnalyticsPrepared() && !analyticsStarted) {
          init();
          analyticsStarted = true;
        }
        result.success(null);
        return;
      }
      if (!analyticsStarted) {
        result.success(null);
        return;
      }
      switch (call.method) {
        case 'onEvent':
          this.trackEvent(call);
          break;
        case 'onProfileSignIn': {
          const account = call.argument('userID') as string;
          if (account && account.length <= 64) onProfileSignIn('wepeiyang', account);
          break;
        }
        case 'onProfileSignOff':
          this.pageStarts.clear();
          onProfileSignOff();
          break;
        case 'onPageStart': {
          const page = call.argument('page') as string;
          if (page) this.pageStarts.set(page, Date.now());
          break;
        }
        case 'onPageEnd': {
          const page = call.argument('page') as string;
          const started = this.pageStarts.get(page);
          this.pageStarts.delete(page);
          if (started !== undefined) onEventObject('wpy_page_view', {
            page_name: page.slice(0, 256),
            elapsed_ms: Math.max(0, Date.now() - started),
          });
          break;
        }
        default:
          result.notImplemented();
          return;
      }
      result.success(null);
    } catch (error) {
      const err = error as BusinessError;
      result.error('ANALYTICS_ERROR', err.message, err.code);
    }
  }

  private trackEvent(call: MethodCall): void {
    const args = call.args as Object[];
    const event = args[0];
    if (typeof event !== 'string' || !event || event.length > 128) return;
    const raw = args[1] as Map<string, Object> | undefined;
    const params: Record<string, string | number> = {};
    raw?.forEach((value, key) => {
      if (key && key.length <= 128) {
        if (typeof value === 'string') params[key] = value.slice(0, 256);
        else if (typeof value === 'number' && Number.isFinite(value)) params[key] = value;
        else if (typeof value === 'bigint' && Number.isSafeInteger(Number(value))) params[key] = Number(value);
      }
    });
    onEventObject(event, params);
  }
}
