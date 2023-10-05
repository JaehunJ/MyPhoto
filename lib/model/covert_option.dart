import 'package:flutter/material.dart';

class ConvertOption {
  double borderHorizontal;
  double borderVertical;
  ImageRatio ratioOption;

  ConvertOption(
      {required this.borderHorizontal, required this.borderVertical, required this.ratioOption});
}

enum ImageRatio{
  RATIO_3_2, RATIO_16_9, RATIO_1_1, RATIO_4_3
}

const RATIO_3_2 = 0;
const RATIO_16_9 = 1;
const RATIO_4_3 = 2;