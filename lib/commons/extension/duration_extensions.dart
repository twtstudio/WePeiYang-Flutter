// @dart = 2.12

part of 'extensions.dart';

extension DurationFormatter on Duration {
  /// Returns a day, hour, minute, second string representation of this `Duration`.
  ///
  ///
  /// Returns a string with days, hours, minutes, and seconds in the
  /// following format: `dd:HH:MM:SS`. For example,
  ///
  ///   var d = new Duration(days:19, hours:22, minutes:33);
  ///    d.dayHourMinuteSecondFormatted();
  String dayHourMinuteSecondFormatted() {
    this.toString();
    String d = this.inDays.toString() + '天';
    String h = this.inHours.remainder(24).toString() + '小时';
    String m = this.inMinutes.remainder(60).toString() + '分钟';
    String s = this.inSeconds.remainder(60).toString() + '秒';
    if(this.inDays > 0) return d + h + '前';
    else if(this.inHours > 0) return h + m + '前';
    else if(this.inMinutes > 0) return m + '前';
    else return s + '前';
  }
}