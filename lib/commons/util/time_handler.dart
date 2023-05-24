class TimeHandler {
  timeHandler(milliSecond) {
    var t = DateTime.now(); //当前时间戳
    ///用的时候传个

    var timeLag = t.difference(milliSecond); //时间戳进行比较
    var dayLag = timeLag.inDays;
    var hourLag = timeLag.inHours;
    var minLag = timeLag.inMinutes;
    var secLag = timeLag.inSeconds;

    if (dayLag > 1 || dayLag == 1) {
      //如果时间差大于24小时,显示：x天前
      return "${dayLag}天了";
    } else if (hourLag < 24 && hourLag > 1) {
      //如果时间差小于24小时，显示：x小时
      return "${hourLag}小时了";
    } else if (minLag > 0 && minLag < 60) {
      //如果时间差小于1小时，显示：x分钟
      return "${minLag}分钟了";
    } else if (secLag > 0 && secLag < 60) {
      //如果时间差小于1分钟
      return "${secLag}秒，冲浪达人啊";
    }
  }
}
