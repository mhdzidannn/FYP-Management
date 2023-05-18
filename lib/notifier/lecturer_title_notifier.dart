import 'package:flutter/widgets.dart';

class FYPTitleNotifier with ChangeNotifier {
  // News _userNewItem;
  // List<Asset> _image = List<Asset>();
  String _adTitle = '';
  int _progress = 0;
  // bool _isImageDone;

  // News get getUserAdd => _userNewItem;
  // int get getProgressVal => _progress;
  // String get getAdtitle => _adTitle;
  // List<Asset> get getAssetImage => _image;
  // bool get getIsImageDone => _isImageDone;

  // set setUserNewItem(News item) {
  //   _userNewItem = item;
  //   notifyListeners();
  // }

  // -------------------------------------------------------------------

  set setProgress(int x) {
    _progress = x;
    notifyListeners();
  }

  set setAdTitle(String title) {
    _adTitle = title;
    notifyListeners();
  }

  updateProgressBarIndicator(bool isincrement) {
    if (isincrement) {
      _progress += 1;
    } else {
      _progress -= 1;
    }
    notifyListeners();
  }
}
