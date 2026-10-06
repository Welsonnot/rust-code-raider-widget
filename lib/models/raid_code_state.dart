// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'package:flutter/foundation.dart';

class RaidCodeState extends ChangeNotifier {
  static const List<String> defaultCodes = ['1234', '1111', '0000'];

  final List<String> codes;
  int _currentIndex = 0;
  String _currentInput = '';
  bool _isError = false;
  String _errorMessage = '';
  int _totalAttempts = 0;
  int _wrongAttempts = 0;
  bool _isCompleted = false;

  RaidCodeState({List<String>? codes}) : codes = codes ?? defaultCodes;

  int get currentIndex => _currentIndex;
  String get currentInput => _currentInput;
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
  int get totalAttempts => _totalAttempts;
  int get wrongAttempts => _wrongAttempts;
  bool get isCompleted => _isCompleted;
  int get totalCodes => codes.length;

  String get currentTargetCode {
    if (_isCompleted || _currentIndex >= codes.length) {
      return '';
    }
    return codes[_currentIndex];
  }

  /// Advance directly to next code (e.g. triggered by global hotkey F8 or Numpad Add)
  void nextCode() {
    _isError = false;
    _errorMessage = '';
    _currentInput = '';
    if (_isCompleted) {
      reset();
      return;
    }
    _totalAttempts++;
    if (_currentIndex + 1 < codes.length) {
      _currentIndex++;
    } else {
      _isCompleted = true;
    }
    notifyListeners();
  }

  /// Step back to previous code (e.g. triggered by global hotkey F7 or Numpad Subtract)
  void previousCode() {
    _isError = false;
    _errorMessage = '';
    _currentInput = '';
    if (_isCompleted) {
      _isCompleted = false;
      _currentIndex = codes.length - 1;
    } else if (_currentIndex > 0) {
      _currentIndex--;
    }
    notifyListeners();
  }

  /// Add a digit (0-9)
  bool? addDigit(String digit) {
    if (_isCompleted) return null;
    if (digit.length != 1 || !RegExp(r'^[0-9]$').hasMatch(digit)) return null;

    // If currently showing an error, clear input on the next digit press
    if (_isError) {
      _isError = false;
      _errorMessage = '';
      _currentInput = '';
    }

    if (_currentInput.length >= 4) {
      return null;
    }

    _currentInput += digit;
    notifyListeners();

    // If 4 digits entered, evaluate immediately
    if (_currentInput.length == 4) {
      _totalAttempts++;
      if (_currentInput == currentTargetCode) {
        // Success!
        _isError = false;
        _errorMessage = '';
        _currentInput = '';
        if (_currentIndex + 1 < codes.length) {
          _currentIndex++;
        } else {
          _isCompleted = true;
        }
        notifyListeners();
        return true;
      } else {
        // Wrong code!
        _wrongAttempts++;
        _isError = true;
        _errorMessage = 'WRONG CODE • TRY AGAIN';
        notifyListeners();
        return false;
      }
    }

    return null;
  }

  /// Remove last entered digit
  void removeLastDigit() {
    if (_isCompleted) return;
    if (_isError) {
      _isError = false;
      _errorMessage = '';
      _currentInput = '';
      notifyListeners();
      return;
    }

    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    if (_isError) {
      _isError = false;
      _errorMessage = '';
      _currentInput = '';
      notifyListeners();
    }
  }

  /// Reset the counter to code 1 (1234)
  void reset() {
    _currentIndex = 0;
    _currentInput = '';
    _isError = false;
    _errorMessage = '';
    _totalAttempts = 0;
    _wrongAttempts = 0;
    _isCompleted = false;
    notifyListeners();
  }
}
