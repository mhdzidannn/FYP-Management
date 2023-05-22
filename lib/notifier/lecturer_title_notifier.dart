import 'package:flutter/widgets.dart';

class FYPTitleNotifier with ChangeNotifier {
  String _adTitle = '';
  int _progress = 0;

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
