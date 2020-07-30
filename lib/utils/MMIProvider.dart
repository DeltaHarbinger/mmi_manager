import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mmi_manager/utils/MMIUtils.dart';

/// Provides tools used to retrieve, update, store and delete MMI codes from MMI
/// database.
class MMIProvider with ChangeNotifier {

  /// Stores a list of all MMI entries.
  List<MMIEntry> _mmiEntries;

  /// Getter for all MMI entries.
  List<MMIEntry> get mmiEntries => _mmiEntries;

  /// Constructor for MMI provider. Ensures that flutter is initialized before
  /// calling [this._loadMMIFromDatabase()].
  MMIProvider() {
    WidgetsFlutterBinding.ensureInitialized();
    this._loadMMIFromDatabase();
  }

  /// Loads all MMI codes from the MMI database and stores them in
  /// [this._mmiEntries].
  Future _loadMMIFromDatabase() async {
    this._mmiEntries = await MMIUtils.getAllMMI();
    notifyListeners();
  }

  /// Stores a specified MMI code into the MMI database
  Future<int> storeMMI(MMIEntry mmiEntry) async {
    int id = await MMIUtils.storeMMI(mmiEntry);
    _mmiEntries.add(mmiEntry);
    notifyListeners();
    return id;
  }
}
