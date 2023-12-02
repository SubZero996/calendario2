int dateToUnix(DateTime date) {
  return date.millisecondsSinceEpoch ~/ 1000;
}

DateTime unixToDateTime(int date) {
  var convert = DateTime.fromMillisecondsSinceEpoch(date * 1000, isUtc: true);
  return convert; //.subtract(const Duration(hours: 12))
}
