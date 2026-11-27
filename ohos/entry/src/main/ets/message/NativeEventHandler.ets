import { Want } from '@kit.AbilityKit';
import { url } from '@kit.ArkTS';
import { MethodCall, MethodCallHandler, MethodChannel, MethodResult } from '@ohos/flutter_ohos';

export class NativeEventHandler implements MethodCallHandler {
  private pending: Record<string, number>[] = [];
  private channel?: MethodChannel;

  attach(channel: MethodChannel): void {
    this.channel = channel;
    channel.setMethodCallHandler(this);
  }

  detach(): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = undefined;
  }

  receive(want: Want): void {
    const provided = want.parameters?.['wpyUri'] ?? this.widgetUri(want);
    const uri = want.uri || (typeof provided === 'string' ? provided : '');
    if (!uri.startsWith('wpy://') || uri.length > 2048) return;
    const event = this.toEvent(uri);
    if (!event) return;
    if (!this.pending.some(value => value['event'] === event['event'] && value['data'] === event['data'])) {
      if (this.pending.length === 16) this.pending.shift();
      this.pending.push(event);
    }
    this.channel?.invokeMethod('eventChanged', null);
  }

  clear(): void {
    this.pending = [];
  }

  private toEvent(uri: string): Record<string, number> | undefined {
    try {
      const target = url.URL.parseURL(uri);
      const host = target.hostname.toLowerCase();
      const page = target.params.get('page');
      if (host === 'school_project' || (host === 'wpy.app' &&
        (target.pathname === '/post' || page === 'post' || page === 'qslt_post'))) {
        const id = host === 'school_project' ? target.pathname.slice(1) :
          target.params.get('id') || target.params.get('post_id') || target.params.get('question_id') || '';
        const post = Number(id);
        return /^\d+$/.test(id) && Number.isSafeInteger(post) && post > 0
          ? { event: 1, data: post } : undefined;
      }
      if (host !== 'wpy.app') return undefined;
      if (target.pathname === '/summary' || page === 'qslt_summary') return { event: 2 };
      switch (target.pathname) {
        case '/schedule': return { event: 4 };
        case '/entryQr': return { event: 6 };
        case '/mailbox': return { event: 7 };
        default: return undefined;
      }
    } catch (_) {
      return undefined;
    }
  }

  private widgetUri(want: Want): string | undefined {
    const params = want.parameters?.['params'];
    if (typeof params === 'string' && params.length <= 2048) {
      try {
        const value = (JSON.parse(params) as Record<string, Object>)['wpyUri'];
        return typeof value === 'string' ? value : undefined;
      } catch (_) {
        return undefined;
      }
    }
    if (params && typeof params === 'object') {
      const value = (params as Record<string, Object>)['wpyUri'];
      return typeof value === 'string' ? value : undefined;
    }
    return undefined;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'getLastEvent') {
      const event = this.pending.shift();
      result.success(event ?? null);
      if (this.pending.length > 0) {
        setTimeout(() => {
          if (this.pending.length > 0) this.channel?.invokeMethod('eventChanged', null);
        }, 0);
      }
    } else {
      result.notImplemented();
    }
  }
}
