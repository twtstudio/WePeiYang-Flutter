import { Want } from '@kit.AbilityKit';
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import {
  refreshScheduleForm, registerScheduleForm, scheduleBinding, scheduleNextRefresh, unregisterScheduleForm,
} from './ScheduleFormData';

export default class ScheduleFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const dir = this.context.getApplicationContext().filesDir;
    const params = want.parameters;
    const extra = params?.['ohos.extra.form'] as Record<string, Object> | undefined;
    const rawId = params?.[formInfo.FormParam.IDENTITY_KEY] ?? extra?.['formId'];
    const size = params?.[formInfo.FormParam.DIMENSION_KEY];
    const dimension = size === 2 ? '2*2' : size === 4 ? '4*4' : '2*4';
    if (typeof rawId === 'string' && rawId) {
      registerScheduleForm(dir, rawId, dimension);
      scheduleNextRefresh(dir, rawId);
    }
    return scheduleBinding(dir, dimension);
  }

  onUpdateForm(formId: string): void {
    refreshScheduleForm(this.context.getApplicationContext().filesDir, formId).catch(() => {});
  }

  onCastToNormalForm(formId: string): void {
    this.onUpdateForm(formId);
  }

  onRemoveForm(formId: string): void {
    unregisterScheduleForm(this.context.getApplicationContext().filesDir, formId);
  }
}
