import { bundleManager, common, Want } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { notificationManager } from '@kit.NotificationKit';
import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import GetuiPush from '@getui/push';

export class PushHandler implements MethodCallHandler {
  private initialized = false;
  private detached = false;
  private initializing?: Promise<string>;
  private generation = 0;
  private cid = '';
  private pushRequested = false;
  private pendingClicks: Want[] = [];
  private readonly context: common.UIAbilityContext;
  private readonly channel: MethodChannel;

  constructor(context: common.UIAbilityContext, channel: MethodChannel) {
    this.context = context;
    this.channel = channel;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'turnOnPushService':
          if (!await notificationManager.isNotificationEnabled()) {
            try {
              await notificationManager.requestEnableNotification(this.context);
            } catch (_) {
              try {
                await notificationManager.openNotificationSettingsWithResult(this.context);
              } catch (_) {
                // Read the actual permission below, including on older releases.
              }
            }
          }
          result.success(await notificationManager.isNotificationEnabled()
            ? 'open push service success' : 'refuse open push');
          break;
        case 'getCid':
          if (!await notificationManager.isNotificationEnabled()) {
            result.success(null);
            break;
          }
          result.success(await this.getCid());
          break;
        case 'turnOffPushService':
          await this.disable();
          result.success(null);
          break;
        case 'getIntentUri': {
          const type = call.argument('type');
          const question = call.argument('question_id');
          let uri: string | null = null;
          if (type === 'mailbox') {
            uri = 'wpy://wpy.app/mailbox';
          } else if (type === 'feedback') {
            if (call.argument('page') === 'summary') uri = 'wpy://wpy.app/summary';
            else if (typeof question === 'number' && Number.isSafeInteger(question) && question > 0) {
              uri = 'wpy://wpy.app/post?id=' + question;
            }
          }
          result.success(uri);
          break;
        }
        default:
          result.notImplemented();
      }
    } catch (error) {
      const err = error as BusinessError;
      result.error('PUSH_ERROR', err.message, err.code);
    }
  }

  async disable(): Promise<void> {
    this.generation++;
    this.pushRequested = false;
    this.pendingClicks = [];
    await this.initializing?.catch(() => '');
    if (this.initialized) GetuiPush.turnOffPush();
  }

  detach(): void {
    this.detached = true;
    this.pendingClicks = [];
  }

  receiveClick(want: Want): void {
    if (!want.parameters?.['gtdata']) return;
    if (this.initialized) {
      this.reportClick(want);
    } else {
      if (this.pendingClicks.length === 8) this.pendingClicks.shift();
      this.pendingClicks.push(want);
    }
  }

  private async getCid(): Promise<string> {
    if (this.detached) return '';
    this.pushRequested = true;
    const generation = this.generation;
    if (!this.initialized) {
      if (!this.initializing) this.initializing = this.initialize();
      try {
        await this.initializing;
      } finally {
        this.initializing = undefined;
      }
    }
    if (this.detached || generation !== this.generation || !this.initialized) return '';
    GetuiPush.turnOnPush();
    return this.cid || GetuiPush.getClientId() || '';
  }

  private async initialize(): Promise<string> {
    const flags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
    const bundle = await bundleManager.getBundleInfoForSelf(flags);
    const metadata = bundle.hapModulesInfo.find(item => item.name === 'entry')?.metadata;
    const appId = metadata?.find(item => item.name === 'GETUI_APPID')?.value;
    if (!appId || appId === 'CONFIGURE_GETUI_APP_ID' || this.detached) return '';
    GetuiPush.setPushCallback({
      onReceiveClientId: (cid: string): void => {
        if (this.detached || !cid || this.cid === cid) return;
        this.cid = cid;
        this.channel.invokeMethod('pushCidChanged', null);
      },
    });
    return new Promise<string>((resolve, reject) => {
      let finished = false;
      const timeout = setTimeout(() => {
        finished = true;
        reject(new Error('Getui initialization timed out'));
      }, 8000);
      try {
        GetuiPush.initialize({
          context: this.context,
          onSuccess: (cid: string) => {
            if (finished) {
              if (!this.pushRequested) GetuiPush.turnOffPush();
              return;
            }
            finished = true;
            clearTimeout(timeout);
            this.initialized = true;
            if (cid) this.cid = cid;
            for (const want of this.pendingClicks) this.reportClick(want);
            this.pendingClicks = [];
            resolve(cid);
          },
          onFailed: (_: string) => {
            if (finished) return;
            finished = true;
            clearTimeout(timeout);
            reject(new Error('Getui initialization failed'));
          },
        });
      } catch (error) {
        finished = true;
        clearTimeout(timeout);
        reject(error);
      }
    });
  }

  private async reportClick(want: Want): Promise<void> {
    try {
      const raw = want.parameters?.['gtdata'];
      const data = (typeof raw === 'string' ? JSON.parse(raw) : raw) as Record<string, Object>;
      const task = data?.['gttask'];
      if (typeof task === 'string' && task) {
        const action = Number(data['gtaction'] as string | number);
        if (task.length <= 128 && action === 60090 && this.cid) {
          const uuid = util.generateRandomUUID().replace(/-/g, '');
          const seed = util.TextEncoder.create('utf-8').encodeInto(task + uuid + this.cid);
          const digest = cryptoFramework.createMd('MD5');
          await digest.update({ data: seed });
          const bytes = (await digest.digest()).data;
          let message = '';
          for (let index = 0; index < 8; index++) message += bytes[index].toString(16).padStart(2, '0');
          GetuiPush.sendFeedbackMessage(task, message, action);
        }
      } else {
        GetuiPush.setClickWant(want);
      }
    } catch (_) {
      // Click reporting should not block navigation.
    }
  }
}
