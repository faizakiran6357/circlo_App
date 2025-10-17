import 'package:flutter/material.dart';

class NavigtationProvider extends ChangeNotifier{
  int index = 0;
  updateIndex(int newIndex) async {
    await Future.delayed(Duration.zero);
    index = newIndex;
    notifyListeners();
  }
}