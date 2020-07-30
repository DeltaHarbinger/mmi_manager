import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mmi_manager/utils/AppStateProvider.dart';
import 'package:mmi_manager/utils/InputProvider.dart';
import 'package:mmi_manager/pages/MMIPage.dart';
import 'package:mmi_manager/pages/SaveMMIPage.dart';

class HomePage extends StatelessWidget {

  /// Defines text styles used in the page
  final TextStyle _numberStyle = TextStyle(fontSize: 28);
  final TextStyle _tutorialTextStyle = TextStyle(fontSize: 24);

  /// Defines a global scaffold key to be used in the page's main Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Shows a dialog containing all specified errors with the compiled MMI code
  void showCompileIssues(Map<int, String> compileResult) {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (context) {
        List<int> keys = compileResult.keys.toList();
        return AlertDialog(
          title: Text("Errors"),
          content: Container(
            height: MediaQuery.of(context).size.height * 1 / 2,
            width: MediaQuery.of(context).size.width * 1 / 2,
            child: ListView.builder(
              itemCount: keys.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                int issueKey = keys[index];
                return ListTile(
                  title: Text(compileResult[issueKey]),
                  subtitle: Text("At position ${issueKey + 1}"),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Function called when the Compile button is pressed. Compiles the MMI using
  /// the pseudo-PDA in MMIUtils through the MMIProvider class. If the code has
  /// issues, a SnackBar is presented with a button to show the issues.
  Future onCompileTap(BuildContext context, InputProvider inputProvider) async {
    Map<int, String> compileResult = inputProvider.compileInput();
    if (compileResult.keys.length == 0) {
      await HapticFeedback.vibrate();
      _scaffoldKey.currentState.hideCurrentSnackBar();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SaveMMIPage(),
        ),
      );
    } else {
      await HapticFeedback.vibrate();
      await HapticFeedback.heavyImpact();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 10),
          content: Text("Invalid MMI entered"),
          action: SnackBarAction(
            label: "See Issues",
            onPressed: () => showCompileIssues(compileResult),
          ),
        ),
      );
    }
  }

  /// Shows a tutorial screen showing basic functions of the HomeScreen
  Future showTutorialMessage(
    BuildContext context,
    AppStateProvider appStateProvider,
  ) async {
    Image keypadImage = Image.asset("assets/Keypad.jpg");
    Image compileImage = Image.asset("assets/Compile.jpg");
    Image savedImage = Image.asset("assets/Saved.jpg");
    if (!appStateProvider.homeScreenTutorialComplete) {
      List<Widget> pages = [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            keypadImage,
            Text(
              "Use the keypad to enter your MMI code",
              style: _tutorialTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            compileImage,
            Text(
              "Press the compile button to validate and save your MMI code",
              style: _tutorialTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            savedImage,
            Text(
              "See saved MMI codes by selecting the folder icon",
              style: _tutorialTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ];
      appStateProvider.homeScreenTutorialComplete = true;
      await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Welcome"),
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 3 / 4,
                width: MediaQuery.of(context).size.width * 3 / 4,
                child: PageView.builder(
                  itemCount: pages.length,
                  itemBuilder: (BuildContext context, int page) => pages[page],
                ),
              ),
              FlatButton(
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: Navigator.of(context).pop,
              ),
            ],
          );
        },
      );
    }
  }

  /// On tap trigger for Exit button. Asks the user whether or not they would
  /// like to exit.
  Future onExitTap(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to exit"),
            content: Text("All unsaved MMI codes will be lost"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: Navigator.of(context).pop,
              ),
              FlatButton(
                child: Text("Exit", style: TextStyle(color: Colors.red)),
                onPressed: () => exit(0),
              ),
            ],
          );
        });
  }

  /// Builds home screen
  @override
  Widget build(BuildContext context) {
    InputProvider inputProvider = context.watch<InputProvider>();
    AppStateProvider appStateProvider = context.watch<AppStateProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showTutorialMessage(context, appStateProvider);
    });
    final List<Widget> numberList = List.generate(
      12,
      (index) {
        String buttonText;
        if (index > 8) {
          buttonText = ['*', '0', '#'][index - 9];
        } else {
          buttonText = "${index + 1}";
        }
        return InkWell(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              buttonText,
              style: _numberStyle,
            ),
            height: MediaQuery.of(context).size.height * 5 / 32,
          ),
          onTap: () {
            inputProvider.addInput(buttonText);
          },
        );
      },
    );

    List<Widget> _barButtons = [
      MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 12,
        child: Icon(Icons.clear),
        onPressed: inputProvider.clearInput,
      ),
      MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 12,
        child: Icon(Icons.settings),
        onPressed: () => onCompileTap(context, inputProvider),
      ),
      MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.height / 12,
        child: Icon(Icons.backspace),
        onPressed: inputProvider.popInput,
        onLongPress: inputProvider.clearInput,
      ),
    ];

    return Consumer<InputProvider>(
      builder: (BuildContext context, InputProvider _input, Widget child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: () => onExitTap(context),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.folder_special,
                  color: Colors.grey[700],
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MMIPage(),
                    ),
                  );
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 32,
              ),
            ],
          ),
          key: _scaffoldKey,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                alignment: Alignment.bottomCenter,
                height: MediaQuery.of(context).size.height / 8,
                child: Text(
                  _input.input,
                  style: _numberStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Table(
                children: [
                  TableRow(children: numberList.sublist(0, 3)),
                  TableRow(children: numberList.sublist(3, 6)),
                  TableRow(children: numberList.sublist(6, 9)),
                  TableRow(children: numberList.sublist(9, 12)),
                ],
              ),
              ButtonBar(
                mainAxisSize: MainAxisSize.max,
                buttonPadding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width / 32,
                  0,
                  MediaQuery.of(context).size.width / 32,
                  0,
                ),
                children: _barButtons,
                alignment: MainAxisAlignment.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
