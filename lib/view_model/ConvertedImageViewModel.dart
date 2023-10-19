import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../model/covert_option.dart';

enum ProgressState { READY, RUN, DONE }

class ConvertedImageViewModel extends ChangeNotifier {
  List<File> _pickImages = [];

  List<File> get pickImages => _pickImages;

  img.Image? _processedImage = null;

  img.Image? get processedImage => _processedImage;

  ProgressState state = ProgressState.READY;

  Future<void> addImage(File file) async {
    pickImages.add(file);
    notifyListeners();
  }

  Future<void> processImage(File image) async {
    state = ProgressState.RUN;
    final imageBytes = await File(image.path).readAsBytes();
    final exifData = await readExifFromBytes(imageBytes);

    final originalImage = img.decodeImage(Uint8List.fromList(imageBytes));

    final exifInfo = {
      'Device Name': exifData['Image Model'] ?? 'N/A',
      'Focal Length': exifData['EXIF FocalLengthIn35mmFilm'] ?? 'N/A',
      'ISO': exifData['EXIF ISOSpeedRatings'] ?? 'N/A',
      'Shutter Speed': exifData['EXIF ExposureTime'] ?? 'N/A',
    };

    var fstop = 'N/A';
    if (exifData['EXIF FNumber'] != null) {
      final fvalues = exifData['EXIF FNumber']?.printable;

      if (fvalues != null && fvalues.isNotEmpty) {
        final splitStr = fvalues.split('/');

        if (splitStr.isNotEmpty) {
          if (splitStr.length > 1) {
            final fvalue =
                (double.parse(splitStr[0]) / double.parse(splitStr[1]))
                    .toStringAsFixed(1);
            fstop = fvalue;
          } else {
            fstop = fvalues[0];
          }
        }
      }
    }

    print('${exifInfo['Device Name']}');
    print('${fstop}');

    if (originalImage != null) {
      final longPixel = originalImage.height > originalImage.width
          ? originalImage.height
          : originalImage.width;
      print('long ${longPixel}');
      //0 == horizontal, 1 == vertical
      final imageOri = originalImage.height > originalImage.width ? 1 : 0;
      
      //원판 인스타 1:1 비율
      img.Image processedImage = img.Image(width: 1080, height: 1080, backgroundColor: img.ColorRgb8(0,0,0));
      //padding 픽셀 피율
      final paddingPixelPer = 0.2;
      //원본 리사이즈
      final resizeHeight = originalImage.height*0.8;
      img.Image resizeImg = img.copyResize(originalImage, width: (originalImage.width*0.8).toInt(), height: (originalImage.height*0.8).toInt());
      final centerX = (1080 - resizeImg.width) ~/ 2;
      final centerY = imageOri == 0 ? (1080 - resizeImg.height) ~/ 2 : (1080 - resizeImg.height) ~/ 4;
      processedImage = img.compositeImage(processedImage, resizeImg, dstY: centerY, dstX: centerX);

      var textY = imageOri == 0 ? 1080 - resizeImg.height ~/ 3 :(1080 - resizeImg.height ~/ 12);

      var exifString =
          "${exifInfo['Device Name'] ?? 'N/A'}, ${exifInfo['Focal Length'] ?? 'N/A'}mm, ISO ${exifInfo['ISO'] ?? 'N/A'}, F${fstop ?? 'N/A'}, ${exifInfo['Shutter Speed'] ?? 'N/A'}s";

      processedImage = img.drawString(processedImage, exifString,
          font: img.arial24,
          color: img.ColorRgb8(255, 255, 255),
          y: textY);

      _processedImage = processedImage;
      state = ProgressState.DONE;
      notifyListeners();
    }
  }
}

class ConvertOptionViewModel extends ChangeNotifier {
  final ConvertOption _option = ConvertOption(
      borderHorizontal: 1,
      borderVertical: 1,
      ratioOption: ImageRatio.RATIO_3_2);

  set borderHorizontal(double value) => _option.borderHorizontal = value;

  set borderVertical(double value) => _option.borderVertical = value;

  set ratioOption(ImageRatio value) => _option.ratioOption = value;

  void changeConvertOption() {
    notifyListeners();
  }
}
