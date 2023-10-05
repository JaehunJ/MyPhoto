import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:proj/main.dart';
import 'package:provider/provider.dart';

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<GridImageProvider>(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemCount: imageProvider.pickImages.length,
      itemBuilder: (context, index) {
        final image = imageProvider.pickImages[index];
        return GestureDetector(
            onTap: () {
              print("tab");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(image)));
            },
            child: Container(
              child: Image.file(image),
              decoration:
              BoxDecoration(border: Border.all(color: Colors.black45)),
            ));
      },
    );
  }
}

class ImagePreviewScreen extends StatefulWidget {
  final File image;

  ImagePreviewScreen(this.image);

  @override
  State<StatefulWidget> createState() {
    return _ImagePreviewScreenState();
  }
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  img.Image? _processedImage;

  @override
  void initState() {
    _processImage();
    super.initState();
  }

  /**
   * 이미지 만들기
   */
  Future<void> _processImage() async {
    final imageBytes = await File(widget.image.path).readAsBytes();
    final exifData = await readExifFromBytes(imageBytes);

    final originalImage = img.decodeImage(Uint8List.fromList(imageBytes));

    final exifInfo = {
      'Device Name': exifData['Image Model'] ?? 'N/A',
      'Focal Length': exifData['EXIF FocalLengthIn35mmFilm'] ?? 'N/A',
      'ISO': exifData['EXIF ISOSpeedRatings'] ?? 'N/A',
      'Shutter Speed': exifData['EXIF ExposureTime'] ?? 'N/A',
    };

    var fstop = 'N/A';
    if(exifData['EXIF FNumber'] != null){
      final fvalues = exifData['EXIF FNumber']?.printable;

      if(fvalues != null && fvalues.isNotEmpty){
        final splitStr = fvalues.split('/');

        if(splitStr.isNotEmpty){
          if(splitStr.length > 1){
            final fvalue = (double.parse(splitStr[0]) / double.parse(splitStr[1])).toStringAsFixed(1);
            fstop = fvalue;
          }else{
            fstop = fvalues[0];
          }
        }
      }
    }

    print('${exifInfo['Device Name']}');
    print('${fstop}');

    if (originalImage != null) {
      final borderSize = (originalImage.width * 0.1).toInt(); // 원하는 테두리 크기
      final width = originalImage.width + (2 * borderSize);
      final height = originalImage.height + (3 * borderSize);
      final x = (width - originalImage.width) ~/ 2;
      final y = (height - originalImage.height) ~/ 3;

      print("org w: ${originalImage.width}, nw: ${width}");

      img.Image processedImage = img.Image(width: width, height: height);

      processedImage = img.fill(processedImage, color: img.ColorRgb8(0, 0, 0));
      processedImage = img.compositeImage(
          processedImage, originalImage, dstX: x, dstY: y.toInt());

      var textY = (height - y);

      var exifString = "${exifInfo['Device Name'] ??
          'N/A'} , ${exifInfo['Focal Length'] ?? 'N/A'} mm , ISO ${exifInfo['ISO'] ??
          'N/A'} , F ${fstop??
          'N/A'} , ${exifInfo['Shutter Speed'] ?? 'N/A'} s";

      processedImage = img.drawString(processedImage, exifString, font: img.arial24, color: img.ColorRgb8(255,255,255), y: textY-24);


      setState(() {
        print("over");
        _processedImage = processedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Image Preview'),
        ),
        body: Center(
          child: _processedImage != null
              ? Image.memory(
              Uint8List.fromList(img.encodeJpg(_processedImage!)))
              : CircularProgressIndicator(),
        ));
  }
}

