import 'package:flutter/material.dart';

class NavProvider with ChangeNotifier {
  int _index = 0;
  bool _openAddProject = false;

  int get index => _index;
  bool get openAddProject => _openAddProject;

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }

  void openAddProjectScreen() {
    _openAddProject = true;
    _index = 1; 
    notifyListeners();
  }

  void resetAddProjectFlag() {
    _openAddProject = false;
    notifyListeners();
  }
}