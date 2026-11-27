import { common } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { detectBarcode, scanCore } from '@kit.ScanKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';

export class MediaHandler implements MethodCallHandler {
  private readonly context: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      switch (call.method) {
        case 'pickImages':
          result.success(await this.pick(call.argument('limit') as number));
          break;
        case 'takePhoto':
          result.success(await this.capture(call.argument('quality') as number | null));
          break;
        case 'compressWithFileAndGetFile': {
          const args = call.args as (string | number | boolean)[];
          if (args[7] !== 0) {
            result.notImplemented();
            break;
          }
          const from = args[0] as string;
          const to = args[4] as string;
          await this.compress(from, to, args[3] as number, args[1] as number, args[2] as number, args[5] as number);
          result.success(to);
          break;
        }
        case 'savePictureToAlbum':
          if (await this.save(call.argument('path') as string)) {
            result.success('success');
          } else {
            result.error('SAVE_CANCELLED', 'Album save was cancelled', null);
          }
          break;
        case 'saveImage':
          result.success(await this.save(call.argument('path') as string));
          break;
        case 'share':
          await this.share(call.argument('paths') as string[] | undefined,
            call.argument('uri') as string | undefined, call.argument('text') as string | undefined);
          result.success('dev.fluttercommunity.plus/share/unavailable');
          break;
        case 'decoder': {
          const path = call.argument('file') as string;
          const codes = await detectBarcode.decode({ uri: fileUri.getUriFromPath(path) }, {
            scanTypes: [scanCore.ScanType.QR_CODE],
            enableMultiMode: false,
            enableAlbum: false,
          });
          result.success(codes.length ? codes[0].originalValue : null);
          break;
        }
        default:
          result.notImplemented();
      }
    } catch (error) {
      const err = error as BusinessError;
      result.error('MEDIA_ERROR', err.message, err.code);
    }
  }

  private async pick(limit: number): Promise<string[]> {
    const options = new photoAccessHelper.PhotoSelectOptions();
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    options.maxSelectNumber = Math.max(1, Math.min(limit, 9));
    const selected = await new photoAccessHelper.PhotoViewPicker().select(options);
    const paths: string[] = [];
    for (const uri of selected.photoUris) {
      const extension = this.extension(uri);
      const path = this.cacheDirectory() + '/photo_' + util.generateRandomUUID() + extension;
      await this.copy(uri, path, true);
      paths.push(path);
    }
    return paths;
  }

  private async capture(quality: number | null): Promise<string | null> {
    if (!canIUse('SystemCapability.Multimedia.Camera.Core')) return null;
    const path = this.cacheDirectory() + '/camera_' + util.generateRandomUUID() + '.jpg';
    const file = await fileIo.open(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    await fileIo.close(file);
    let captured = false;
    try {
      const result = await cameraPicker.pick(this.context, [cameraPicker.PickerMediaType.PHOTO], {
        cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
        saveUri: fileUri.getUriFromPath(path),
      });
      if (result.resultCode !== 0 || !result.resultUri) return null;
      if (typeof quality === 'number') {
        const compressed = path + '.jpg';
        try {
          await this.compress(path, compressed, quality);
          await fileIo.rename(compressed, path);
        } catch (error) {
          await fileIo.unlink(compressed).catch(() => {});
          throw error;
        }
      }
      captured = true;
      return path;
    } finally {
      if (!captured) await fileIo.unlink(path).catch(() => {});
    }
  }

  private async compress(from: string, to: string, quality: number, width = 0, height = 0, rotation = 0): Promise<void> {
    const input = await fileIo.open(from, fileIo.OpenMode.READ_ONLY);
    try {
      const source = image.createImageSource(input.fd);
      try {
        const size = (await source.getImageInfo()).size;
        const scale = width > 0 && height > 0 ? Math.min(1, Math.max(width / size.width, height / size.height)) : 1;
        const pixels = await source.createPixelMap({
          desiredSize: {
            width: Math.max(1, Math.round(size.width * scale)),
            height: Math.max(1, Math.round(size.height * scale)),
          },
          rotate: rotation,
        });
        try {
          const packer = image.createImagePacker();
          try {
            const output = await fileIo.open(to, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC);
            try {
              await packer.packToFile(pixels, output.fd, {
                format: 'image/jpeg', quality: Math.max(0, Math.min(100, quality)),
              });
            } finally {
              await fileIo.close(output);
            }
          } finally {
            await packer.release();
          }
        } finally {
          await pixels.release();
        }
      } finally {
        await source.release();
      }
    } finally {
      await fileIo.close(input);
    }
  }

  private async save(path: string): Promise<boolean> {
    const helper = photoAccessHelper.getPhotoAccessHelper(this.context);
    const inputUri = fileUri.getUriFromPath(path);
    const output = await helper.showAssetsCreationDialog([inputUri], [{
      title: path.substring(path.lastIndexOf('/') + 1).replace(/\.[^.]+$/, ''),
      fileNameExtension: this.extension(path).slice(1),
      photoType: photoAccessHelper.PhotoType.IMAGE,
      subtype: photoAccessHelper.PhotoSubtype.DEFAULT,
    }]);
    if (!output.length) return false;
    await this.copy(inputUri, output[0], false);
    return true;
  }

  private async share(paths?: string[], uri?: string, text?: string): Promise<void> {
    let data: systemShare.SharedData;
    if (paths?.length) {
      const dir = this.cacheDirectory() + '/share';
      if (!fileIo.accessSync(dir)) fileIo.mkdirSync(dir, true);
      data = new systemShare.SharedData(await this.shareRecord(dir, paths[0]));
      for (let index = 1; index < paths.length; index++) {
        data.addRecord(await this.shareRecord(dir, paths[index]));
      }
    } else if (uri || text) {
      data = new systemShare.SharedData({
        utd: uri ? utd.UniformDataType.HYPERLINK : utd.UniformDataType.PLAIN_TEXT,
        content: uri || text,
      });
    } else {
      throw new Error('Share data is empty');
    }
    const controller = new systemShare.ShareController(data);
    await controller.show(this.context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE,
    });
  }

  private async shareRecord(dir: string, path: string): Promise<systemShare.SharedRecord> {
    const extension = this.extension(path);
    const fileName = 'image_' + util.generateRandomUUID() + extension;
    const dest = dir + '/' + fileName;
    await this.copy(path, dest, true);
    const type = utd.getUniformDataTypeByFilenameExtension(extension, utd.UniformDataType.IMAGE);
    return {
      utd: type || utd.UniformDataType.IMAGE,
      uri: fileUri.getUriFromPath(dest),
      title: fileName,
    };
  }

  private extension(path: string): string {
    const match = /\.(jpeg|jpg|png|gif|webp|heic|heif|bmp)(?:[?#]|$)/i.exec(path);
    return match ? '.' + match[1].toLowerCase() : '.jpg';
  }

  private cacheDirectory(): string {
    const dir = this.context.cacheDir + '/we_pei_yang_flutter';
    if (!fileIo.accessSync(dir)) fileIo.mkdirSync(dir, true);
    return dir;
  }

  private async copy(from: string, to: string, create: boolean): Promise<void> {
    const input = await fileIo.open(from, fileIo.OpenMode.READ_ONLY);
    try {
      const output = await fileIo.open(to, create
        ? fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC
        : fileIo.OpenMode.WRITE_ONLY);
      try {
        await fileIo.copyFile(input.fd, output.fd);
      } finally {
        await fileIo.close(output);
      }
    } finally {
      await fileIo.close(input);
    }
  }
}
