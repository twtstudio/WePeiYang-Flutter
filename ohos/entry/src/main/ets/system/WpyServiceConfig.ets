import { common } from '@kit.AbilityKit';
import { util, url } from '@kit.ArkTS';
import { rcp } from '@kit.RemoteCommunicationKit';

interface WpyServiceConfig {
  entryQrUrl?: string;
  webViewsUrl?: string;
}

export function readServiceConfig(context: common.Context): WpyServiceConfig {
  try {
    const raw = context.resourceManager.getRawFileContentSync('wpy_services.json');
    const values = JSON.parse(util.TextDecoder.create('utf-8').decodeToString(raw)) as WpyServiceConfig;
    return values ?? {};
  } catch (_) {
    return {};
  }
}

export function isHttpsUrl(value: string): boolean {
  if (typeof value !== 'string' || !value.startsWith('https://')) return false;
  try {
    const address = url.URL.parseURL(value);
    return address.hostname.length > 0 && !address.username && !address.password;
  } catch (_) {
    return false;
  }
}

export async function fetchJsonText(endpoint: string, headers?: rcp.RequestHeaders): Promise<string> {
  const session = rcp.createSession({
    requestConfiguration: {
      transfer: { autoRedirect: false, timeout: { connectMs: 3500, transferMs: 6500 } },
    },
  });
  try {
    const response = await session.fetch(new rcp.Request(endpoint, 'GET', headers));
    if (response.statusCode !== 200) throw new Error('HTTP request failed');
    const body = response.toString();
    if (!body || body.length > 65536) throw new Error('Invalid response body');
    return body;
  } finally {
    session.close();
  }
}
