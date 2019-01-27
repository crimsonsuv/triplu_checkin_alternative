import 'package:flutter/material.dart';

TextStyle textStyle (Color color, FontWeight weight, double size, {FontStyle style = FontStyle.normal, double lineHeight = 1}){
  return new TextStyle(color: color, fontWeight: weight, fontSize: size, height: lineHeight);
}

String capitalize(String input) {
  if (input == null) {
    throw new ArgumentError("string: $input");
  }
  if (input.length == 0) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1);
}