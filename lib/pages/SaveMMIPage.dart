import 'package:flutter/material.dart';
import 'package:mmi_manager/utils/InputProvider.dart';
import 'package:mmi_manager/utils/MMIProvider.dart';
import 'package:mmi_manager/utils/MMIUtils.dart';
import 'package:provider/provider.dart';

class SaveMMIPage extends StatelessWidget {
  /// Scaffold key used to reference the scaffold in the current scope
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Stores the MMI in the Input field
  Future onSaveTab(BuildContext context) async {
    InputProvider inputProvider = context.read<InputProvider>();
    MMIProvider mmiProvider = context.read<MMIProvider>();
    String name = inputProvider.mmiNameController.text;
    String code = inputProvider.input;
    if (name == "") {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Please enter a name for the MMI"),
        ),
      );
      return;
    }
    if (!MMIUtils.validateMMI(code)) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Your MMI seems to be invalid"),
        ),
      );
      return;
    }
    Map<String, dynamic> data = {
      "name": name,
      "code": code,
    };

    FocusScope.of(context).unfocus();
    int resultId = await mmiProvider.storeMMI(
      MMIEntry.fromJSON(data),
    );
    inputProvider.mmiNameController.text = "";
    inputProvider.clearInput();
    Navigator.of(context).pop();
  }

  List<Widget> buttonRow(BuildContext context) {
    InputProvider inputProvider = context.watch<InputProvider>();
    return [
      IconButton(
        icon: Icon(Icons.cancel, color: Colors.red),
        onPressed: () {
          inputProvider.mmiNameController.text = "";
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
        },
        iconSize: 72,
      ),
      IconButton(
        icon: Icon(Icons.check, color: Colors.green),
        onPressed: () => onSaveTab(context),
        iconSize: 72,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    InputProvider _inputProvider = context.watch<InputProvider>();

    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width / 8,
          MediaQuery.of(context).size.height / 32,
          MediaQuery.of(context).size.width / 8,
          MediaQuery.of(context).size.height / 32,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 16,
            ),
            Text(
              "Save",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
            ),
            TextField(
              controller: _inputProvider.mmiNameController,
              autofocus: true,
              style: TextStyle(fontSize: 24),
              decoration: InputDecoration(
                labelText: "Name (e.g. Check Credit)",
                labelStyle: TextStyle(fontSize: 18),
                helperText: "Set a name for this MMI code",
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 32,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: buttonRow(context),
            ),
          ],
        ),
      ),
    );
  }
}
