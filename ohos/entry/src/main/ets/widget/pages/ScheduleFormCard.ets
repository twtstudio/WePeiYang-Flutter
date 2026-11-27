import { ScheduleCourse } from '../ScheduleFormData';

const formStorage = new LocalStorage();

/**
 * 星期手写体底图，与 Android 小组件共用同一套素材
 * （android/app/src/main/res/drawable/{monday..sunday}.png）。
 */
const DAY_ART: Record<number, Resource> = {
  1: $r('app.media.monday'),
  2: $r('app.media.tuesday'),
  3: $r('app.media.wednesday'),
  4: $r('app.media.thursday'),
  5: $r('app.media.friday'),
  6: $r('app.media.saturday'),
  7: $r('app.media.sunday'),
};

// 与 Android widget_schedule_card_item.xml 对齐的排版常量：
// 卡片底 #FFFFFF / 圆角 12dp，课程名 14sp 粗体 #000000，教室与时间 13.33sp #A2A2A2，
// 左侧色条 2.67×37.33dp tint #4f586b。
const CARD_BG = '#FFFFFF';
const TEXT_NAME = '#000000';
const TEXT_META = '#A2A2A2';
const BAR_COLOR = '#4F586B';

@Entry(formStorage)
@Component
struct ScheduleFormCard {
  @LocalStorageProp('courses') courses: ScheduleCourse[] = [];
  @LocalStorageProp('isEmpty') isEmpty: boolean = true;
  // 系统在添加卡片时注入当前卡片尺寸，如 "2*2"、"2*4"、"4*4"
  @LocalStorageProp('formDimension') formDimension: string = '2*4';
  @LocalStorageProp('weekday') weekday: number = 1;
  // 课表数据尚未同步（首次添加或数据被清理），与「今天没课」要区分开
  @LocalStorageProp('hasData') hasData: boolean = false;

  private isHuge(): boolean {
    return this.formDimension === '4*4';
  }

  private isSmall(): boolean {
    return this.formDimension === '2*2';
  }

  /** 星期底图高度 */
  private artHeight(): number {
    return this.isHuge() ? 54 : (this.isSmall() ? 32 : 34);
  }

  private artWidth(): string {
    return this.isHuge() ? '38%' : (this.isSmall() ? '62%' : '50%');
  }

  private nameSize(): number {
    return this.isHuge() ? 17 : (this.isSmall() ? 13 : 14);
  }

  private metaSize(): number {
    return this.isHuge() ? 14 : (this.isSmall() ? 12 : 13);
  }

  /** 2×2 窄卡片里教室与时间分两行，色条要跟着变高 */
  private barHeight(): number {
    if (this.isSmall()) {
      return 46;
    }
    return this.isHuge() ? 42 : 36;
  }

  /** 空态文案与 Android widget_empty_view_day/night.xml 对齐 */
  private emptyText(): string {
    if (!this.hasData) {
      return '打开微北洋\n同步今日课表';
    }
    const hour = new Date().getHours();
    return hour >= 6 && hour <= 18 ? '今日无课 :)\n做点有意义的事吧' : '夜深了\n做个早睡的人吧~';
  }

  private dayArt(): Resource {
    return DAY_ART[this.weekday] ?? DAY_ART[1];
  }

  /**
   * 单条课程。窄卡片（2×2）把教室、时间各放一行，
   * 避免时间把教室挤到只剩几个 vp。
   */
  @Builder
  courseRow(item: ScheduleCourse, inlineMeta: boolean) {
    Row() {
      Column()
        .width(3)
        .height(this.barHeight())
        .borderRadius(2)
        .backgroundColor(BAR_COLOR);
      Column() {
        Text(item.name)
          .fontSize(this.nameSize())
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_NAME)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        if (inlineMeta) {
          Row() {
            Text(item.location)
              .layoutWeight(1)
              .fontSize(this.metaSize())
              .fontColor(TEXT_META)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
            Text(item.time)
              .fontSize(this.metaSize())
              .fontColor(TEXT_META)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 6 });
          }
          .width('100%')
          .margin({ top: 2 });
        } else {
          Text(item.location)
            .width('100%')
            .fontSize(this.metaSize())
            .fontColor(TEXT_META)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 2 });
          Text(item.time)
            .width('100%')
            .fontSize(this.metaSize())
            .fontColor(TEXT_META)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 1 });
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 6, right: 4 });
    }
    .width('100%')
    .padding({ left: 6, right: 6, top: 4, bottom: 4 });
  }

  build() {
    Column() {
      // 星期手写体底图（与 Android 一致：顶部、靠左、等比缩放）
      Row() {
        Image(this.dayArt())
          .width(this.artWidth())
          .height(this.artHeight())
          .objectFit(ImageFit.Contain);
        Blank();
      }
      .width('100%')
      .margin({ bottom: 6 });

      if (this.isEmpty || this.courses.length === 0) {
        Column() {
          Text(this.emptyText())
            .fontSize(this.isSmall() ? 14 : 16)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_NAME)
            .lineHeight(this.isSmall() ? 20 : 22)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 8, top: 4 })
        .alignItems(HorizontalAlign.Start);
      } else {
        // 卡片内滚动查看今天全部课程（List 原生支持卡片能力）
        List({ space: 6 }) {
          ForEach(
            this.courses,
            (item: ScheduleCourse, index: number) => {
              ListItem() {
                this.courseRow(item, !this.isSmall());
              }
            },
            (item: ScheduleCourse, index: number) => index.toString()
          );
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(CARD_BG)
    .borderRadius(12)
    .onClick(() => {
      // 点击卡片直达课表页；路由参数在 EntryAbility 侧转发给 Flutter
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { 'wpyUri': 'wpy://wpy.app/schedule' }
      });
    });
  }
}
