import { common } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { Any, BinaryMessenger, EventChannel, EventSink, MethodCall, MethodCallHandler, MethodResult, StreamHandler } from '@ohos/flutter_ohos';
import { microphoneGranted } from '../system/PermissionHandler';

const SAMPLE_RATE = 16000;
const MAX_BYTES = SAMPLE_RATE * 2 * 60;
const EVENTS_PREFIX = 'com.llfbandit.record/events/';

class RecorderEvents implements StreamHandler {
  private sink?: EventSink;

  onListen(_args: Any, sink: EventSink): void {
    this.sink = sink;
  }

  onCancel(_args: Any): void {
    this.sink = undefined;
  }

  report(state: number): void {
    this.sink?.success(state);
  }
}

export class AudioRecordingHandler implements MethodCallHandler {
  private capturer?: audio.AudioCapturer;
  private chunks: ArrayBuffer[] = [];
  private length = 0;
  private queue: Promise<void> = Promise.resolve();
  private readonly context: common.UIAbilityContext;
  private readonly messenger: BinaryMessenger;
  private readonly events = new Map<string, RecorderEvents>();
  private owner?: string;

  constructor(context: common.UIAbilityContext, messenger: BinaryMessenger) {
    this.context = context;
    this.messenger = messenger;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.queue = this.queue.then(() => this.handle(call, result)).catch((error: BusinessError) => {
      result.error('RECORDING_ERROR', error.message, error.code);
    });
  }

  private async handle(call: MethodCall, result: MethodResult): Promise<void> {
    const id = call.argument('recorderId') as string;
    switch (call.method) {
      case 'create': {
        const events = new RecorderEvents();
        const channel = new EventChannel(this.messenger, EVENTS_PREFIX + id);
        channel.setStreamHandler(events);
        this.events.set(id, events);
        result.success(null);
        break;
      }
      case 'hasPermission':
        result.success(await microphoneGranted(this.context, call.argument('request') !== false));
        break;
      case 'isRecording':
        result.success(this.owner === id && this.capturer !== undefined);
        break;
      case 'isPaused':
        result.success(false);
        break;
      case 'start':
        if (this.owner !== undefined) {
          result.error('RECORDING_BUSY', 'Another recording is active', null);
          break;
        }
        await this.start();
        this.owner = id;
        this.events.get(id)?.report(1);
        result.success(null);
        break;
      case 'stop': {
        if (this.owner !== id) {
          result.success(null);
          break;
        }
        try {
          result.success(await this.stop(id));
        } finally {
          this.owner = undefined;
          this.events.get(id)?.report(2);
        }
        break;
      }
      case 'cancel':
      case 'dispose':
        if (this.owner === id) {
          this.owner = undefined;
          await this.cancel();
          this.events.get(id)?.report(2);
        }
        if (call.method === 'dispose') {
          this.events.delete(id);
          this.messenger.setMessageHandler(EVENTS_PREFIX + id, null);
        }
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  private async start(): Promise<void> {
    if (this.capturer) return;
    const capturer = await audio.createAudioCapturer({
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW,
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_VOICE_RECOGNITION,
        capturerFlags: 0,
      },
    });
    this.capturer = capturer;
    this.chunks = [];
    this.length = 0;
    try {
      capturer.on('readData', (buffer: ArrayBuffer) => {
        const length = Math.min(buffer.byteLength, MAX_BYTES - this.length) & ~1;
        if (length === 0 || this.capturer !== capturer) return;
        this.length += length;
        this.chunks.push(buffer.slice(0, length));
      });
      await capturer.start();
    } catch (error) {
      await this.cancel();
      throw error;
    }
  }

  private async stop(id: string): Promise<string | null> {
    const capturer = this.capturer;
    if (!capturer) return null;
    this.capturer = undefined;
    try {
      capturer.off('readData');
      await capturer.stop();
    } finally {
      await capturer.release();
    }
    const chunks = this.chunks;
    const length = this.length;
    this.chunks = [];
    this.length = 0;
    if (!length) return null;
    const cache = this.context.cacheDir + '/we_pei_yang_flutter';
    if (!fileIo.accessSync(cache)) fileIo.mkdirSync(cache, true);
    const path = cache + '/voice_' + id.replace(/[^a-zA-Z0-9-]/g, '_') + '.wav';
    const file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
    try {
      fileIo.writeSync(file.fd, this.wav(chunks, length));
    } finally {
      fileIo.closeSync(file);
    }
    return path;
  }

  private wav(chunks: ArrayBuffer[], length: number): ArrayBuffer {
    const buffer = new ArrayBuffer(44 + length);
    const bytes = new Uint8Array(buffer);
    const header = new DataView(buffer);
    const encoder = util.TextEncoder.create('utf-8');
    bytes.set(encoder.encodeInto('RIFF'), 0);
    header.setUint32(4, 36 + length, true);
    bytes.set(encoder.encodeInto('WAVEfmt '), 8);
    header.setUint32(16, 16, true);
    header.setUint16(20, 1, true);
    header.setUint16(22, 1, true);
    header.setUint32(24, SAMPLE_RATE, true);
    header.setUint32(28, SAMPLE_RATE * 2, true);
    header.setUint16(32, 2, true);
    header.setUint16(34, 16, true);
    bytes.set(encoder.encodeInto('data'), 36);
    header.setUint32(40, length, true);
    let offset = 44;
    for (const chunk of chunks) {
      bytes.set(new Uint8Array(chunk), offset);
      offset += chunk.byteLength;
    }
    return buffer;
  }

  private async cancel(): Promise<void> {
    const capturer = this.capturer;
    this.capturer = undefined;
    this.chunks = [];
    this.length = 0;
    if (!capturer) return;
    try {
      capturer.off('readData');
      await capturer.stop();
    } catch (_) {
      // The capturer may still be in its initial state.
    } finally {
      await capturer.release();
    }
  }

  detach(): void {
    this.queue = this.queue.then(async () => {
      for (const id of this.events.keys()) this.messenger.setMessageHandler(EVENTS_PREFIX + id, null);
      this.events.clear();
      this.owner = undefined;
      await this.cancel();
    }).catch(() => {});
  }
}
