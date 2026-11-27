
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { EventChannel, FlutterAbility, FlutterEngine, MethodCallHandler, MethodChannel, StandardMethodCodec } from '@ohos/flutter_ohos';
import { MediaHandler } from '../media/MediaHandler';
import { NativeEventHandler } from '../message/NativeEventHandler';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { PushHandler } from '../push/PushHandler';
import { AudioRecordingHandler } from '../speech/AudioRecordingHandler';
import { PreferencesHandler } from '../storage/PreferencesHandler';
import { SystemHandler } from '../system/SystemHandler';
import { ConnectivityHandler } from '../system/ConnectivityHandler';
import { CloudConfigHandler } from '../system/CloudConfigHandler';
import { PermissionHandler } from '../system/PermissionHandler';
import { StatisticsHandler } from '../statistics/StatisticsHandler';
import { AppUpdateHandler } from '../update/AppUpdateHandler';
import { ScheduleWidgetHandler } from '../widget/ScheduleWidgetHandler';
import { EntryQrForms } from '../widget/EntryQrForms';

export default class EntryAbility extends FlutterAbility {
  private readonly events = new NativeEventHandler();
  private channels: MethodChannel[] = [];
  private push?: PushHandler;
  private audio?: AudioRecordingHandler;
  private connectivity?: ConnectivityHandler;
  private initialPushWant?: Want;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.events.receive(want);
    if (want.parameters?.['gtdata']) this.initialPushWant = want;
    super.onCreate(want, launchParam);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    super.onNewWant(want, launchParam);
    this.events.receive(want);
    this.push?.receiveClick(want);
  }

  configureFlutterEngine(engine: FlutterEngine): void {
    super.configureFlutterEngine(engine);
    GeneratedPluginRegistrant.registerWith(engine);
    this.events.attach(this.channel(engine, 'message'));
    const system = new SystemHandler(this.context);
    this.channel(engine, 'ohos_system', system);
    this.channel(engine, 'device_info', system);
    this.channel(engine, 'local_setting', system);
    this.channel(engine, 'umeng_statistics', new StatisticsHandler());
    this.channel(engine, 'cloud_config', new CloudConfigHandler(this.context));
    this.bind(engine, 'dev.fluttercommunity.plus/package_info', system);
    this.bind(engine, 'flutter.baseflow.com/permissions/methods', new PermissionHandler(this.context));
    const campusForms = new EntryQrForms(this.context);
    const widget = new ScheduleWidgetHandler(this.context, campusForms);
    this.channel(engine, 'widget', widget);
    this.channel(engine, 'preferences', new PreferencesHandler(this.context,
      async (logout: boolean, hadPush: boolean) => {
        if (logout) {
          this.events.clear();
          if (hadPush) this.push?.disable().catch(() => {});
        }
        await widget.clear().catch(() => {});
      }, () => campusForms.clear().catch(() => {})));
    const media = new MediaHandler(this.context);
    this.channel(engine, 'saveImg', media);
    this.bind(engine, 'gallery_saver', media);
    this.bind(engine, 'qr_code_tools', media);
    this.bind(engine, 'dev.fluttercommunity.plus/share', media);
    this.bind(engine, 'flutter_image_compress', media);
    this.channel(engine, 'update', new AppUpdateHandler(this.context));

    const messenger = engine.getDartExecutor().getBinaryMessenger();
    const connectivity = new ConnectivityHandler();
    this.connectivity = connectivity;
    this.bind(engine, 'dev.fluttercommunity.plus/connectivity', connectivity);
    new EventChannel(messenger, 'dev.fluttercommunity.plus/connectivity_status').setStreamHandler(connectivity);
    this.audio = new AudioRecordingHandler(this.context, messenger);
    this.bind(engine, 'com.llfbandit.record/messages', this.audio);
    const pushChannel = this.channel(engine, 'push');
    this.push = new PushHandler(this.context, pushChannel);
    pushChannel.setMethodCallHandler(this.push);
    if (this.initialPushWant) {
      this.push.receiveClick(this.initialPushWant);
      this.initialPushWant = undefined;
    }
  }

  private channel(engine: FlutterEngine, name: string, handler?: MethodCallHandler): MethodChannel {
    return this.bind(engine, 'com.twt.service/' + name, handler);
  }

  private bind(engine: FlutterEngine, name: string, handler?: MethodCallHandler): MethodChannel {
    const channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(),
      name, StandardMethodCodec.INSTANCE);
    if (handler) channel.setMethodCallHandler(handler);
    this.channels.push(channel);
    return channel;
  }

  onDestroy(): void {
    this.events.detach();
    this.audio?.detach();
    this.push?.detach();
    this.connectivity?.detach();
    for (const channel of this.channels) channel.setMethodCallHandler(null);
    this.channels = [];
    super.onDestroy();
  }
}
