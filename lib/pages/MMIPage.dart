import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:ussd_service/ussd_service.dart';
import 'package:provider/provider.dart';
import 'package:sim_data/sim_data.dart';
import 'package:mmi_manager/utils/MMIProvider.dart';
import 'package:mmi_manager/utils/MMIUtils.dart';

class MMIPage extends StatelessWidget {
  /// Shows a dialog with the result of executing a manufacturer MMI code
  Future showManufacturerMMIResult(String mmiCode, BuildContext context) async {
    List<String> imeis = await ImeiPlugin.getImeiMulti();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("IMEI codes"),
          content: Container(
            width: MediaQuery.of(context).size.width * 3 / 4,
            height: MediaQuery.of(context).size.height * 3 / 4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: imeis.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(imeis[index]),
                  subtitle: Text("IMEI Sim ${index + 1}"),
                );
              },
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        );
      },
    );
  }

  /// Shows the result of executing a carrier MMI code
  Future showCarrierMMIResult(
      int selectedID, String mmiCode, BuildContext context) async {
    String ussdMessage = await UssdService.makeRequest(
      selectedID,
      mmiCode,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            child: Text(ussdMessage),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Close",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        );
      },
    );
  }

  /// Retrieves the ID of the sim card to be used by the user
  Future<int> getSelectedId(BuildContext context, List<SimCard> cards) async {
    int selectedID;
    await showDialog(
      context: context,
      builder: (context) {
        List<ListTile> dialogOptions = List.generate(
          cards.length,
          (index) {
            SimCard sim = cards[index];
            return ListTile(
              title: Text(sim.carrierName),
              subtitle: Text(sim.displayName),
              onTap: () {
                selectedID = sim.subscriptionId;
                Navigator.of(context).pop();
              },
            );
          },
        );
        dialogOptions.add(
          ListTile(
            title: Text(
              "Cancel",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            onTap: Navigator.of(context).pop,
          ),
        );
        return SimpleDialog(
          title: Text("Select the Sim Card to use"),
          children: dialogOptions,
        );
      },
    );
    return selectedID;
  }

  /// Launched an MMI/USSD code that is sent and processed by the carrier
  Future launchCarrierMMI(String mmiCode, BuildContext context) async {
    try {
      SimData simData = await SimDataPlugin.getSimData();
      List<SimCard> simCards = simData.cards;
      int selectedID = await getSelectedId(context, simCards);
      if (selectedID != null) {
        showCarrierMMIResult(selectedID, mmiCode, context);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error executing MMI code"),
            content: Text(
              "An error was encountered when attempting to run this MMI code",
            ),
          );
        },
      );
    }
  }

  /// Checks if the MMI is a hardware MMI or Carrier USSD code and executes it.
  Future launchMMI(mmiCode, context) async {
    if (mmiCode == "*#06#" || mmiCode == "*#0*#") {
      showManufacturerMMIResult(mmiCode, context);
    } else {
      launchCarrierMMI(mmiCode, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    MMIProvider _mmiProvider = context.watch<MMIProvider>();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Saved",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          MMIEntry entry = _mmiProvider.mmiEntries[index];
          String mmiCode = entry.code;
          return ListTile(
            title: Text(entry.name),
            subtitle: Text(entry.code),
            onTap: () async => await launchMMI(mmiCode, context),
          );
        },
        itemCount: _mmiProvider.mmiEntries.length,
      ),
    );
  }
}
