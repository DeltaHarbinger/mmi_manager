import 'package:sqflite/sqflite.dart';

class MMIUtils {

  /// Regex that may be used to quickly validate MMI codes
  static RegExp _mmiCodeRegex = RegExp(
    r"^\*#{0,1}([0-9]+\*{0,1})+#$",
    multiLine: false,
  );

  /// Takes an MMI code and parses it using a pseudo-PDA to validate it.
  /// Returns a Map containing errors detected while parsing.
  static Map<int, String> compileMMI(String code) {
    ///Initialized stack with $ on top
    String stack = "\$";
    /// Initializes issues map
    Map<int, String> issues = {};
    /// If the code is less than 3 characters long, the user is told that the
    /// code is too short to be an MMI code
    if(code.length < 3) {
      issues[0] = "MMI code needs to be at least 3 characters";
      return issues;
    }
    /// Iterates over each character in the provided MMI code.
    for(int i = 0; i < code.length; i++) {
      /// Checks if the first character is a '*'
      if(i == 0) {
        if(code[i] != "*") {
          issues[i] = "MMI code must begin with an asterisk '*'";
        }
        continue;
      }
      /// Checks if the final character in the code is a '#'
      if(i == code.length - 1) {
        if(code[i] == "#") {
          if(stack[stack.length - 1] == "0") {
            stack = stack.substring(0, stack.length - 1);
          }
        } else {
          issues[i] = "MMI code must end with a number sign '#'";
        }
        continue;
      }
      /// Checks if a digit is entered. If a '0' is not at the top of the stack,
      /// a '0' is placed there.
      switch(code.codeUnitAt(i)) {
        case 48:
        case 49:
        case 50:
        case 51:
        case 52:
        case 53:
        case 54:
        case 55:
        case 56:
        case 57:
          if(stack[stack.length - 1] != "0"){
            stack += "0";
          }
          break;
        /// Checks if the input is a '*'. If a '0' is at the top fo the stack,
        /// and removes it if it is. Logs an error otherwise.
        case 42:
          if(stack[stack.length - 1] == "0") {
            stack = stack.substring(0, stack.length - 1);
          } else {
            issues[i] = "Unexpected * found'";
          }
          break;
        /// Checks if the input is a '#'. Checks if it is the second character
        /// or the final character in the string.
        case 35:
          if(i != 1 && i != stack.length - 1) {
            issues[i] = "Unexpected '#' found";
          }
          break;
      }
    }
    /// Returns all issues logged
    return issues;
  }

  /// Returns the result of validating the MMI using the regex
  static bool validateMMI(String input) {
    return _mmiCodeRegex.hasMatch(input);
  }

  /// Database used to store saved MMI codes
  static Database _db;

  /// Initializes database
  static Future<bool> initDatabase() async {
    _db = await openDatabase(
      "mmi.db",
      version: 1,
      onCreate: (Database db, int version) {
        db.execute(
          "CREATE TABLE mmi (id INTEGER PRIMARY KEY, name TEXT, code TEXT)",
        );
      },
    );
    return _db.isOpen;
  }

  /// Retrieves all MMI codes from the database and returns them as a list of
  /// MMI entries
  static Future<List<MMIEntry>> getAllMMI() async {
    if (_db == null || !_db.isOpen) {
      await initDatabase();
    }
    List<Map<String, dynamic>> mmiRecords = await _db.query("mmi");
    List<MMIEntry> mmiEntries = [];
    mmiRecords.forEach((element) => mmiEntries.add(MMIEntry.fromJSON(element)));
    return mmiEntries;
  }

  /// Stores a given MMI entry in the database
  static Future<int> storeMMI(MMIEntry mmiEntry) async {
    if (_db == null || !_db.isOpen) {
      await initDatabase();
    }
    return await _db.insert(
      "mmi",
      mmiEntry.toJSON(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates a specified MMI code in the database
  static Future<int> updateMMI(int id, {String name, String code}) async {
    if (_db == null || !_db.isOpen) {
      await initDatabase();
    }
    Map<String, dynamic> newValue;
    if(name != null){
      newValue["name"] = name;
    }
    if(code != null) {
      newValue["code"] = code;
    }
    return await _db.update("mmi", newValue, where: 'id = $id', whereArgs: [id]);
  }
}

/// Class used to represent an MMI code along with information such as its name
/// and code as a String. Also allows parsing to and from JSONs/Maps
class MMIEntry {
  int _id;
  String _name;
  String _code;

  int get id => _id;

  String get name => _name;

  String get code => _code;

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      "id": this.id,
      "name": this.name,
      "code": this.code,
    };
  }

  MMIEntry.fromJSON(Map<String, dynamic> json) {
    this._id = json["id"];
    this._code = json["code"];
    this._name = json["name"];
  }
}
