import { AbilityStage } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { InternalPlugin, preInit } from '@umeng/analytics';

let analyticsPrepared = false;

export function isAnalyticsPrepared(): boolean {
  return analyticsPrepared;
}

export default class EntryAbilityStage extends AbilityStage {
  onCreate(): void {
    try {
      const raw = this.context.resourceManager.getRawFileContentSync('umconfig.json');
      const config = JSON.parse(util.TextDecoder.create('utf-8').decodeToString(raw)) as Record<string, string>;
      const appKey = config['appKey'];
      if (typeof appKey !== 'string' || !appKey.trim()) return;
      preInit({ context: this.context.getApplicationContext(), plugins: [new InternalPlugin()] });
      analyticsPrepared = true;
    } catch (_) {
      // Statistics is optional. Initialization must never block app startup.
    }
  }
}
