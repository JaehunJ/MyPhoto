import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proj/const/colors.dart';
import 'package:proj/item/image_grid.dart';
import 'package:proj/model/covert_option.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Home()
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => GridImageProvider()),
              ChangeNotifierProvider(create: (_) => ConvertOptionProvider())
            ],
            child: HomeBody(),
          )
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
        ],
      ),
      backgroundColor: tdBGColor,
    );
  }
}

class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<GridImageProvider>(context);

    return Column(
      children: [
        Flexible(child: ImageGrid()),
        Divider(thickness: 1, color: Colors.black12,),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  final imageFile = File(pickedFile.path);
                  await imageProvider.addImage(imageFile);
                }
              },
              child: Text("추가"),
            ),
            SizedBox(width: 8,),
            ElevatedButton(
              onPressed: () {},
              child: Text("변환"),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}

class GridImageProvider extends ChangeNotifier {
  List<File> pickImages = [];

  Future<void> addImage(File file) async {
    pickImages.add(file);
    notifyListeners();
  }
}

class ConvertOptionProvider extends ChangeNotifier {
  final ConvertOption _option = ConvertOption(borderHorizontal: 1, borderVertical: 1, ratioOption: ImageRatio.RATIO_3_2);

  void setBorderHotizontal(double value){
    _option.borderHorizontal = value;
    notifyListeners();
  }

  void setBorderVertical(double value){
    _option.borderVertical = value;
    notifyListeners();
  }

  void setRatioOption(ImageRatio value){
    _option.ratioOption = value;
    notifyListeners();
  }
}


