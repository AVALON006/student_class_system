import 'package:flutter/material.dart';

class CrossGlobalModel extends ChangeNotifier {
  bool _multi = false;
  bool get multi => _multi;
  void switchMulti() {
    _multi = !_multi;
    notifyListeners();
  }
}
