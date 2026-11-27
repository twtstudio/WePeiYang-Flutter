import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { fetchJsonText, isHttpsUrl, readServiceConfig } from './WpyServiceConfig';

const DEFAULT_PAGES: Record<string, string>[] = [
  { page: '年终总结', url: 'http://summary.twtstudio.com/', channels: 'saveImg' },
  { page: '大学重开模拟器', url: 'http://restart.twtstudio.com/', channels: 'saveImg' },
];

export class CloudConfigHandler implements MethodCallHandler {
  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method !== 'getWebViews') {
      result.notImplemented();
      return;
    }
    result.success(await this.pages());
  }

  private async pages(): Promise<Record<string, string>[]> {
    const endpoint = readServiceConfig(this.context).webViewsUrl ?? '';
    if (!isHttpsUrl(endpoint)) return DEFAULT_PAGES;
    const cache = await preferences.getPreferences(this.context, 'wepeiyang_cloud_config').catch(() => undefined);
    try {
      const pages = this.parse(await fetchJsonText(endpoint));
      if (cache) {
        await cache.put('pages', JSON.stringify(pages))
          .then(() => cache.put('endpoint', endpoint)).then(() => cache.flush()).catch(() => {});
      }
      return pages;
    } catch (_) {
      try {
        if (cache && await cache.get('endpoint', '') === endpoint) {
          const stored = await cache.get('pages', '');
          if (typeof stored === 'string' && stored) return this.parse(stored);
        }
      } catch (_) {}
      return DEFAULT_PAGES;
    }
  }

  private parse(body: string): Record<string, string>[] {
    const records = JSON.parse(body) as Record<string, string>[];
    if (!Array.isArray(records) || records.length > 64) throw new Error('Invalid H5 configuration');
    const result: Record<string, string>[] = [];
    for (const record of records) {
      if (!record) throw new Error('Invalid H5 page');
      const page = record['page'];
      const address = record['url'];
      const rawChannels = record['channels'];
      if (typeof page !== 'string' || !page.trim() ||
          typeof address !== 'string' || !/^https?:\/\/[^\s/]+/i.test(address) ||
          typeof rawChannels !== 'string') throw new Error('Invalid H5 page');
      const channels = rawChannels.split(',').map(item => item.trim())
        .filter(item => item === 'share' || item === 'saveImg');
      result.push({ page: page.trim(), url: address, channels: channels.join(',') });
    }
    return result;
  }
}
