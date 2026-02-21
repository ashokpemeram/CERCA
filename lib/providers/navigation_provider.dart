import 'package:flutter/foundation.dart';

/// Provider for bottom navigation state
class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index >= 0 && index <= 4) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateToMap() => setIndex(0);
  void navigateToPrecautions() => setIndex(1);
  void navigateToSOS() => setIndex(2);
  void navigateToContacts() => setIndex(3);
  void navigateToRequestAid() => setIndex(4);
}
