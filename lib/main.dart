import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmi_manager/utils/AppStateProvider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mmi_manager/pages/HomePage.dart';
import 'package:mmi_manager/utils/InputProvider.dart';
import 'package:mmi_manager/utils/MMIProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  /// Initializes all Providers used in the application
  final InputProvider _inputProvider = InputProvider();
  final MMIProvider _mmiProvider = MMIProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();

  /// Checks if the user has accepted/declined permission to use phone features.
  /// If not, the user is prompted to accept/decline the permission
  void checkPermissions() async {
    bool phonePermissionUndetermined = await Permission.phone.isUndetermined;
    if(phonePermissionUndetermined) {
      await Permission.phone.request();
    }
  }

  /// Builds HomePage with all providers in it's context
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    checkPermissions();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _inputProvider),
        ChangeNotifierProvider.value(value: _mmiProvider),
        ChangeNotifierProvider.value(value: _appStateProvider),
      ],
      builder: (BuildContext context, Widget child) => MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
