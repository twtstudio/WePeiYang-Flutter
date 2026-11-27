import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { publishSchedule } from './ScheduleFormData';
import { EntryQrForms } from './EntryQrForms';

export class ScheduleWidgetHandler implements MethodCallHandler {
  private pending: Promise<void> = Promise.resolve();
  private readonly context: common.UIAbilityContext;
  private readonly campusForms: EntryQrForms;

  constructor(context: common.UIAbilityContext, campusForms: EntryQrForms) {
    this.context = context;
    this.campusForms = campusForms;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'publishEntryQr') {
      this.campusForms.publish(call.argument('account') as string, call.argument('code') as string,
        Number(call.argument('expiresAt')))
        .then(() => result.success(null))
        .catch((err: BusinessError) => result.error('ENTRY_QR_WIDGET_UPDATE_FAILED', err.message, err.code));
      return;
    }
    if (call.method !== 'refreshScheduleWidget') {
      result.notImplemented();
      return;
    }
    const snapshot = call.argument('snapshot') as string;
    this.publish(snapshot).then(() => result.success(null)).catch((err: BusinessError) => {
      result.error('WIDGET_WRITE_FAILED', err.message, err.code);
    });
  }

  clear(): Promise<void> {
    return this.publish('');
  }

  private publish(snapshot: string): Promise<void> {
    const task = this.pending.then(() => publishSchedule(this.context.getApplicationContext().filesDir, snapshot));
    this.pending = task.catch(() => {});
    return task;
  }
}
