import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/locker.dart';
import '../services/locker_service.dart';

class LockerProvider with ChangeNotifier {
  final LockerService _lockerService = LockerService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
  
  // Lockers data from Firestore
  List<Locker> _lockers = [];
  bool _isLoading = false;

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
  List<Locker> get lockers => _lockers;
  bool get isLoading => _isLoading;

  /// Initialize lockers from Firestore
  Future<void> loadLockers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Initialize default lockers if needed (first time only)
      await _lockerService.initializeDefaultLockers();
      
      // Get initial snapshot
      final snapshot = await FirebaseFirestore.instance.collection('lockers').get();
      _lockers = snapshot.docs.map((doc) => Locker.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error loading lockers: $e');
      _lockers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribe to real-time locker updates
  StreamSubscription? _lockerSubscription;
  void subscribeToLockers() {
    _lockerSubscription = _lockerService.getLockersStream().listen((updatedLockers) {
      _lockers = updatedLockers;
      notifyListeners();
    });
  }

  void unsubscribeFromLockers() {
    _lockerSubscription?.cancel();
    _lockerSubscription = null;
  }
  
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

  /// Rent a locker and update Firestore
  Future<bool> rentLocker({
    required String lockerId,
    required String otp,
    required String location,
    required DateTime rentalEndTime,
    required Duration totalRentalDuration,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Update Firestore
      await _lockerService.rentLocker(lockerId, user.uid, totalRentalDuration);
      
      // Update local state
      _hasRentedLocker = true;
      _lockerId = lockerId;
      _otp = otp;
      _location = location;
      _rentalEndTime = rentalEndTime;
      _totalRentalDuration = totalRentalDuration;
      _rentedLockerId = lockerId;
      _rentedUntil = rentalEndTime;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error renting locker: $e');
      return false;
    }
  }

  /// Add coins/time to a rented locker
  Future<bool> addTimeToLocker(int coins, Duration time) async {
    try {
      if (_lockerId == null) return false;
      
      await _lockerService.addLockerTime(_lockerId!, time.inMinutes, coins.toDouble());
      
      // Update local state
      _totalRentalDuration = (_totalRentalDuration ?? Duration.zero) + time;
      _rentedUntil = (_rentedUntil ?? DateTime.now()).add(time);
      _rentalEndTime = _rentedUntil;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error adding time: $e');
      return false;
    }
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
  
  /// Get locker by ID from the list
  Locker? getLockerById(String id) {
    try {
      return _lockers.firstWhere((locker) => locker.id == id);
    } catch (e) {
      return null;
    }
  }
}
