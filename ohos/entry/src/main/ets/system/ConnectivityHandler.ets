import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Any, EventSink, MethodCall, MethodCallHandler, MethodResult, StreamHandler } from '@ohos/flutter_ohos';

export class ConnectivityHandler implements MethodCallHandler, StreamHandler {
  private observer?: connection.NetConnection;

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'check') {
      result.success(this.types());
    } else {
      result.notImplemented();
    }
  }

  onListen(_args: Any, sink: EventSink): void {
    this.detach();
    const observer = connection.createNetConnection();
    this.observer = observer;
    const report = (): void => {
      if (this.observer === observer) sink.success(this.types());
    };
    observer.on('netAvailable', report);
    observer.on('netLost', report);
    observer.on('netCapabilitiesChange', report);
    observer.register((error: BusinessError) => {
      if (!error) report();
    });
  }

  onCancel(_args: Any): void {
    this.detach();
  }

  detach(): void {
    const observer = this.observer;
    this.observer = undefined;
    observer?.unregister(() => {});
  }

  private types(): string[] {
    try {
      const network = connection.getDefaultNetSync();
      if (network.netId === 0) return ['none'];
      const bearers = connection.getNetCapabilitiesSync(network).bearerTypes;
      const types = bearers.map<string>((type) => {
        switch (type) {
          case connection.NetBearType.BEARER_WIFI: return 'wifi';
          case connection.NetBearType.BEARER_CELLULAR: return 'mobile';
          case connection.NetBearType.BEARER_ETHERNET: return 'ethernet';
          case connection.NetBearType.BEARER_BLUETOOTH: return 'bluetooth';
          case connection.NetBearType.BEARER_VPN: return 'vpn';
          default: return 'other';
        }
      });
      return types.length ? types : ['other'];
    } catch (_) {
      return ['none'];
    }
  }
}
