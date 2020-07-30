import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'MMIUtils.dart';

/// Stores input collected form the user and tracks input fields for MMI code
/// input and MMI name input.
class InputProvider with ChangeNotifier {

  /// Represents input for MMI code
  String _input;

  /// Getter for MMI code
  String get input => _input;

  /// Text editing controller for fields used to accept the name of the MMI code
  /// entered by the user.
  TextEditingController _textEditingController = TextEditingController();

  /// Getter for MMI name text edit controller.
  TextEditingController get mmiNameController => _textEditingController;

  /// Constructor for InputProvider. Initializes input as an empty string.
  InputProvider(){
    this._input = "";
  }

  /// Optional InputProvider constructor which allows specification of input.
  InputProvider.withInput(this._input);

  /// Concatenates a string to the current input if the string is below the
  /// maximum length. Notifies pages listening for changes to update their UI.
  void addInput(String input){
    if(input.length < 78){
      this._input += input;
    }
    notifyListeners();
  }

  /// Removes the last character from the current input. Notifies pages
  /// listening for changes to update their UI.
  void popInput(){
    if(this._input.length > 0) {
      this._input = _input.substring(0, _input.length - 1);
    }
    notifyListeners();
  }

  /// Resets the MMI input to a blank string. Notifies pages listening for
  /// changes to update their UI.
  void clearInput() {
    this._input = "";
    notifyListeners();
  }

  /// Validates MMI using basic regular expression in MMIUtils class.
  bool valid() {
    return MMIUtils.validateMMI(this._input);
  }

  /// Uses the compiler in MMIUtils to attempt to compile the text in the code
  /// input field. Returns a map containing all errors found during compilation.
  Map<int, String> compileInput() {
    return MMIUtils.compileMMI(this._input);
  }
}