import 'package:flutter/material.dart';

class LockerProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  
  // Rental state
  bool _hasRentedLocker = false;
  String? _lockerId;
  String? _otp;
  String? _location;
  DateTime? _rentalEndTime;
  Duration? _totalRentalDuration;
  
  // Track rented locker status
  String? _rentedLockerId;
  DateTime? _rentedUntil;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  bool get hasRentedLocker => _hasRentedLocker;
  String? get lockerId => _lockerId;
  String? get otp => _otp;
  String? get location => _location;
  DateTime? get rentalEndTime => _rentalEndTime;
  Duration? get totalRentalDuration => _totalRentalDuration;
  String? get rentedLockerId => _rentedLockerId;
  DateTime? get rentedUntil => _rentedUntil;

  // Check if rental is still active
  bool isRentalActive() {
    if (!_hasRentedLocker || _rentedUntil == null) return false;
    return DateTime.now().isBefore(_rentedUntil!);
  }

  void login(String userName) {
    _isLoggedIn = true;
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _hasRentedLocker = false;
    _lockerId = null;
    _otp = null;
    _location = null;
    _rentalEndTime = null;
    _totalRentalDuration = null;
    _rentedLockerId = null;
    _rentedUntil = null;
    notifyListeners();
  }

  void rentLocker({
    required String lockerId,
    required String otp,
    required String location,
    required DateTime rentalEndTime,
    required Duration totalRentalDuration,
  }) {
    _hasRentedLocker = true;
    _lockerId = lockerId;
    _otp = otp;
    _location = location;
    _rentalEndTime = rentalEndTime;
    _totalRentalDuration = totalRentalDuration;
    _rentedLockerId = lockerId;
    _rentedUntil = rentalEndTime;
    notifyListeners();
  }

  void endSession() {
    _hasRentedLocker = false;
    _lockerId = null;
    _otp = null;
    _location = null;
    _rentalEndTime = null;
    _totalRentalDuration = null;
    _rentedLockerId = null;
    _rentedUntil = null;
    notifyListeners();
  }

  // Check if a specific locker is currently rented
  bool isLockerRented(String lockerId) {
    return _rentedLockerId == lockerId && isRentalActive();
  }
}
