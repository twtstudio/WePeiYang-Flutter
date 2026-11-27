const entryQrStorage = new LocalStorage();

@Entry(entryQrStorage)
@Component
struct EntryQrFormCard {
  @LocalStorageProp('status') status: string = 'empty';
  @LocalStorageProp('code') code: string = '';
  @LocalStorageProp('canRefresh') canRefresh: boolean = false;
  @LocalStorageProp('expiresAt') @Watch('updateExpiry') expiresAt: number = 0;
  @State private expired: boolean = false;
  private readonly timer = new TextTimerController();

  private updateExpiry(): void {
    this.expired = this.expiresAt <= Date.now();
    if (!this.expired) {
      this.timer.reset();
      this.timer.start();
    }
  }

  private refresh(): void {
    if (this.status === 'loading') return;
    if (!this.canRefresh || this.status === 'signed_out') {
      this.openApp();
      return;
    }
    postCardAction(this, { action: 'message', params: { action: 'refresh' } });
  }

  private openApp(): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: { wpyUri: 'wpy://wpy.app/entryQr' },
    });
  }

  private hint(): string {
    if (this.status === 'signed_out') return '请先登录';
    if (this.status === 'loading') return '正在刷新…';
    if (this.status === 'failed') return '刷新失败，请重试';
    if (this.status === 'ready') return '二维码已过期';
    return this.canRefresh ? '点击刷新获取二维码' : '打开应用获取二维码';
  }

  build() {
    Column({ space: 4 }) {
      Row() {
        Text($r('app.string.shortcut_entry_qr'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1C2430')
          .layoutWeight(1)
          .onClick(() => this.openApp())
        Text(this.canRefresh ? '刷新' : '打开')
          .fontSize(13)
          .fontColor('#1764C0')
          .padding({ left: 6, right: 4, top: 4, bottom: 4 })
          .onClick(() => this.refresh())
      }
      .width('100%')

      if (this.code && !this.expired && this.expiresAt > Date.now()) {
        Column({ space: 3 }) {
          QRCode(this.code)
            .width(90)
            .height(90)
            .onClick(() => this.refresh())
          TextTimer({
            isCountDown: true,
            count: Math.max(1, this.expiresAt - Date.now()),
            controller: this.timer,
          })
            .format('mm:ss')
            .fontSize(12)
            .fontColor('#5D6776')
            .onAppear(() => this.timer.start())
            .onTimer(() => {
              if (Date.now() >= this.expiresAt - 500) this.expired = true;
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Text(this.hint())
            .fontSize(13)
            .fontColor('#5D6776')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.refresh())
      }
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}
