//Color Constants
import 'package:flutter/painting.dart';

//for converting Hex code to native flutter color code.
int getColorHexFromStr(String colorStr)
{
  colorStr = "FF" + colorStr;
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
      // A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 97 && hexDigit <= 102) {
      // a..f
      val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
    } else {
      throw new FormatException("An error occurred when converting a color");
    }
  }
  return val;
}

final Color kColor_white = new Color(getColorHexFromStr("FFFFFF"));
final Color kColor_green_theme = new Color(getColorHexFromStr("00AD79"));
final Color kColor_dark_text = new Color(getColorHexFromStr("33333D"));

