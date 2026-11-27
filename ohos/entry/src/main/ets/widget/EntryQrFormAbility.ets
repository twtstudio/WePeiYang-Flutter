import { Want } from '@kit.AbilityKit';
import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { EntryQrForms } from './EntryQrForms';

export default class EntryQrFormAbility extends FormExtensionAbility {
  private forms?: EntryQrForms;
  private readonly refreshing = new Set<string>();

  onAddForm(want: Want): formBindingData.FormBindingData {
    const forms = this.getForms();
    const id = want.parameters?.[formInfo.FormParam.IDENTITY_KEY];
    const temporary = want.parameters?.[formInfo.FormParam.TEMPORARY_KEY] === true;
    if (typeof id === 'string' && !temporary && forms.register(id)) this.onUpdateForm(id);
    return forms.binding();
  }

  onCastToNormalForm(id: string): void {
    if (this.getForms().register(id)) this.onUpdateForm(id);
  }

  onUpdateForm(id: string): void {
    if (this.refreshing.has(id)) return;
    this.refreshing.add(id);
    this.getForms().refresh(id).catch(() => {}).finally(() => { this.refreshing.delete(id); });
  }

  onFormEvent(id: string, message: string): void {
    try {
      const data = JSON.parse(message) as Record<string, string>;
      if (data['action'] === 'refresh') this.onUpdateForm(id);
    } catch (_) {}
  }

  onRemoveForm(id: string): void {
    this.getForms().unregister(id);
  }

  private getForms(): EntryQrForms {
    if (!this.forms) this.forms = new EntryQrForms(this.context);
    return this.forms;
  }
}
