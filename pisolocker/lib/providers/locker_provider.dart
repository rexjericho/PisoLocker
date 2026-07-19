import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  static const String _activeLockerKey = 'active_locker_id';

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
      
      // Cleanup any expired locker sessions
      await _lockerService.cleanupExpiredLockers();
      
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
    // Keep rental state for session persistence across logout/login
    // Only clear when endSession() is called or time expires
    notifyListeners();
  }

  /// Load active locker from local storage (called after login)
  Future<void> loadActiveLockerFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLockerId = prefs.getString(_activeLockerKey);
      
      // If no current user, clear everything
      if (_auth.currentUser == null) {
        await clearActiveLocker();
        return;
      }
      
      // ALWAYS search Firestore for any lockers rented by the current user
      // This ensures we find the correct locker even if localStorage has stale data
      await _findActiveRentalInFirestore();
      
    } catch (e) {
      debugPrint('Error loading active locker from storage: $e');
      // On error, clear state to be safe
      await clearActiveLocker();
    }
  }
  
  /// Restore rental state from Firestore data
  Future<void> _restoreRentalState(Map<String, dynamic> data, String lockerId) async {
    _hasRentedLocker = true;
    _lockerId = lockerId;
    _otp = data['otp'] as String?;
    _location = data['location'] as String?;
    _rentedLockerId = lockerId;
    
    // Handle rental end time
    final endTimeData = data['rentalEndTime'];
    if (endTimeData is Timestamp) {
      _rentalEndTime = endTimeData.toDate();
      _rentedUntil = _rentalEndTime;
      
      // Calculate total duration based on remaining time
      final now = DateTime.now();
      if (_rentalEndTime!.isAfter(now)) {
        _totalRentalDuration = _rentalEndTime!.difference(now);
      } else {
        // Rental expired, clean up
        await clearActiveLocker();
        return;
      }
    }
    
    notifyListeners();
  }
  
  /// Search Firestore for any active rentals by the current user
  Future<void> _findActiveRentalInFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      await clearActiveLocker();
      return;
    }
    
    // Query for lockers rented by this user with Occupied status
    final snapshot = await FirebaseFirestore.instance
        .collection('lockers')
        .where('rentedBy', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Occupied')
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      // Found an active rental for this user
      final doc = snapshot.docs.first;
      final data = doc.data();
      await _restoreRentalState(data, doc.id);
      
      // Save this locker ID to local storage for next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeLockerKey, doc.id);
    } else {
      // No active rental found, clear storage
      await clearActiveLocker();
    }
  }

  /// Save active locker ID to local storage
  Future<void> _saveActiveLockerToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_lockerId != null) {
        await prefs.setString(_activeLockerKey, _lockerId!);
      }
    } catch (e) {
      debugPrint('Error saving active locker to storage: $e');
    }
  }

  /// Clear active locker from local storage
  Future<void> clearActiveLocker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeLockerKey);
    } catch (e) {
      debugPrint('Error clearing active locker from storage: $e');
    }
    
    // Also clear local state
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

      // Check if user already has an active rental
      if (_hasRentedLocker && isRentalActive()) {
        throw Exception('You already have an active rental. Please end it first.');
      }

      // Also check Firestore for any active rentals by this user
      final userLockers = await FirebaseFirestore.instance
          .collection('lockers')
          .where('rentedBy', isEqualTo: user.uid)
          .where('status', isEqualTo: 'Occupied')
          .get();
      
      if (userLockers.docs.isNotEmpty) {
        throw Exception('You already have an active rental. Please end it first.');
      }

      // Rent locker and get OTP from service
      final generatedOtp = await _lockerService.rentLocker(lockerId, user.uid, totalRentalDuration);
      
      // Update local state with generated OTP
      _hasRentedLocker = true;
      _lockerId = lockerId;
      _otp = generatedOtp; // Use the OTP generated by the service
      _location = location;
      _rentalEndTime = rentalEndTime;
      _totalRentalDuration = totalRentalDuration;
      _rentedLockerId = lockerId;
      _rentedUntil = rentalEndTime;
      
      // Save to local storage for persistence
      await _saveActiveLockerToStorage();
      
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

  Future<void> endSession() async {
    try {
      if (_lockerId != null && _auth.currentUser != null) {
        // Update Firestore to release the locker
        await FirebaseFirestore.instance
            .collection('lockers')
            .doc(_lockerId)
            .update({
          'status': 'Available',
          'rentedBy': FieldValue.delete(),
          'otp': FieldValue.delete(),
          'rentalEndTime': FieldValue.delete(),
          'lockStatus': 'Unlocked',
        });
        
        debugPrint('Locker $_lockerId released successfully');
      }
    } catch (e) {
      debugPrint('Error releasing locker: $e');
    } finally {
      // Clear from local storage and state
      await clearActiveLocker();
    }
  }

  /// Toggle lock status between Locked and Unlocked
  Future<void> toggleLockStatus() async {
    try {
      if (_lockerId == null || _auth.currentUser == null) return;
      
      final currentLocker = getLockerById(_lockerId!);
      if (currentLocker == null) return;
      
      final newStatus = currentLocker.lockStatus == 'Locked' ? 'Unlocked' : 'Locked';
      
      await FirebaseFirestore.instance
          .collection('lockers')
          .doc(_lockerId)
          .update({'lockStatus': newStatus});
      
      debugPrint('Locker $_lockerId lock status changed to: $newStatus');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling lock status: $e');
    }
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
