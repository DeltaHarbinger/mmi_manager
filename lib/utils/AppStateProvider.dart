import 'package:flutter/foundation.dart';

class AppStateProvider with ChangeNotifier {
  bool appInitTriggered;
  bool homeScreenTutorialComplete;
  bool mmiListTutorialComplete;
  bool mmiSaveTutorialComplete;

  AppStateProvider({
    this.appInitTriggered = false,
    this.homeScreenTutorialComplete = false,
    this.mmiListTutorialComplete = false,
    this.mmiSaveTutorialComplete = false,
  });
}
