bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

String parseNumericString(String s) {
  String newS = "";
  s.runes.forEach((int rune) {
    var character = new String.fromCharCode(rune);
    if (isNumeric(character)) {
      newS += character;
    }
  });
  return newS;
}

void main() {
  List<int> data = [0, 51, 54, 50, 51, 32, 49, 57, 53, 49, 32, 57, 55, 13, 10];
  String msg = String.fromCharCodes(data);
  msg = msg.replaceAll('\n', '');
  // print("original msg: ${msg}");
  List<String> _blMessages = msg.split(" ");
  // print("messages: ${_blMessages}");
  String fStr = _blMessages[0].replaceAll(RegExp(r"\s+"), "");
  String newfStr = "";
  fStr.runes.forEach((int rune) {
    var character = new String.fromCharCode(rune);
    if (isNumeric(character)) {
      newfStr += character;
    }
  });
  // // String fStr = "3623";
  String dStr = "${_blMessages[1]}";
  String cStr = "${_blMessages[2]}";
  print("${newfStr}");
  print("${dStr}");
  print("${cStr}");
  double f = double.tryParse("${newfStr}") ?? 0;
  double d = double.tryParse("${dStr}") ?? 0;
  double c = double.tryParse("${cStr}") ?? 0;
  print(f);
  print(d);
  print(c);
  // print("${_blMessages[0]} ${_blMessages[1]} ${_blMessages[2]}");
  // double _fishDepth = double.parse("${_blMessages[0]}.0");
  // double _oceanDepth = double.parse("${_blMessages[1]}.0");
  // double _conf = double.parse("${_blMessages[2]}.0");
  // print("fishdepth: $_fishDepth - oceadepth: $_oceanDepth - conf: $_conf");

  // String str = "157.0";
  // double d = double.parse(str);
  // print(d);
}
