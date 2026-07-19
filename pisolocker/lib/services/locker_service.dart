import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/locker.dart';

/// Service class for managing locker operations with Firestore
class LockerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'lockers';

  /// Generate random 4-digit OTP
  String _generateOTP() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Get a stream of all lockers
  Stream<List<Locker>> getLockersStream() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Locker.fromFirestore(doc))
          .toList();
    });
  }

  /// Get a single locker by ID
  Future<Locker?> getLockerById(String lockerId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(lockerId).get();
      if (doc.exists) {
        return Locker.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting locker: $e');
      return null;
    }
  }

  /// Update locker status
  Future<void> updateLockerStatus(String lockerId, LockerStatus status) async {
    try {
      await _firestore.collection(_collectionName).doc(lockerId).update({
        'status': _statusToString(status),
      });
    } catch (e) {
      debugPrint('Error updating locker status: $e');
      rethrow;
    }
  }

  /// Rent a locker - returns the generated OTP
  Future<String> rentLocker(String lockerId, String userId, Duration duration) async {
    try {
      final lockerRef = _firestore.collection(_collectionName).doc(lockerId);
      final otp = _generateOTP();
      final rentalEndTime = DateTime.now().add(duration);

      // Use transaction to ensure atomic update
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(lockerRef);
        
        if (!snapshot.exists) {
          throw Exception('Locker does not exist');
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        final rentedBy = data['rentedBy'] as String?;
        final endTimeData = data['rentalEndTime'] as Timestamp?;

        // Check if locker is truly available or if it's an expired session
        if (status != 'Available') {
          // If occupied, check if it's expired
          if (endTimeData != null) {
            final endTime = endTimeData.toDate();
            if (endTime.isBefore(DateTime.now())) {
              // Session expired - allow takeover and clean up old data
              debugPrint('Taking over expired locker session: $lockerId');
            } else {
              // Still active and not by this user
              if (rentedBy != userId) {
                throw Exception('Locker is currently occupied by another user');
              }
            }
          } else if (rentedBy != userId) {
            throw Exception('Locker is not available');
          }
        }

        // Update locker with rental info and OTP
        transaction.update(lockerRef, {
          'status': 'Occupied',
          'rentedBy': userId,
          'rentalEndTime': Timestamp.fromDate(rentalEndTime),
          'remainingTimeMinutes': duration.inMinutes,
          'currentBalance': (data['currentBalance'] as num? ?? 0.0) + 0.0,
          'otp': otp,
        });
      });

      return otp;
    } catch (e) {
      debugPrint('Error renting locker: $e');
      rethrow;
    }
  }

  /// Add balance/time to a rented locker
  Future<void> addLockerTime(String lockerId, int minutes, double balance) async {
    try {
      final lockerDoc = await _firestore.collection(_collectionName).doc(lockerId).get();
      if (!lockerDoc.exists) return;

      final data = lockerDoc.data()!;
      final currentRemainingMinutes = data['remainingTimeMinutes'] as int? ?? 0;
      final currentBalance = data['currentBalance'] as num? ?? 0.0;
      final currentRentalEnd = (data['rentalEndTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      // Extend rental end time
      final newRentalEnd = currentRentalEnd.add(Duration(minutes: minutes));
      
      await _firestore.collection(_collectionName).doc(lockerId).update({
        'remainingTimeMinutes': currentRemainingMinutes + minutes,
        'currentBalance': currentBalance + balance,
        'rentalEndTime': Timestamp.fromDate(newRentalEnd),
      });
    } catch (e) {
      debugPrint('Error adding time to locker: $e');
      rethrow;
    }
  }

  /// Release a locker (end rental)
  Future<void> releaseLocker(String lockerId) async {
    try {
      await _firestore.collection(_collectionName).doc(lockerId).update({
        'status': 'Available',
        'rentedBy': FieldValue.delete(),
        'rentalEndTime': FieldValue.delete(),
        'remainingTimeMinutes': FieldValue.delete(),
        'currentBalance': 0.0,
        'otp': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error releasing locker: $e');
      rethrow;
    }
  }

  /// Check and release any expired locker sessions
  Future<void> cleanupExpiredLockers() async {
    try {
      final now = Timestamp.now();
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: 'Occupied')
          .where('rentalEndTime', isLessThan: now)
          .get();

      for (final doc in snapshot.docs) {
        debugPrint('Cleaning up expired locker: ${doc.id}');
        await doc.reference.update({
          'status': 'Available',
          'rentedBy': FieldValue.delete(),
          'rentalEndTime': FieldValue.delete(),
          'remainingTimeMinutes': FieldValue.delete(),
          'currentBalance': 0.0,
          'otp': FieldValue.delete(),
        });
      }
      
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Cleaned up ${snapshot.docs.length} expired locker(s)');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired lockers: $e');
    }
  }

  /// Initialize default lockers (for first-time setup)
  Future<void> initializeDefaultLockers() async {
    try {
      final defaultLockers = [
        {'lockerCode': 'Locker 1', 'location': 'Ground Floor - Near Entrance', 'status': 'Available'},
        {'lockerCode': 'Locker 2', 'location': 'Ground Floor - Near Entrance', 'status': 'Available'},
        {'lockerCode': 'Locker 3', 'location': 'First Floor - Hallway A', 'status': 'Available'},
        {'lockerCode': 'Locker 4', 'location': 'First Floor - Hallway A', 'status': 'Available'},
        {'lockerCode': 'Locker 5', 'location': 'Second Floor - Near Elevator', 'status': 'Available'},
      ];

      for (final lockerData in defaultLockers) {
        final existingLockers = await _firestore
            .collection(_collectionName)
            .where('lockerCode', isEqualTo: lockerData['lockerCode'])
            .get();

        if (existingLockers.docs.isEmpty) {
          await _firestore.collection(_collectionName).add({
            'lockerCode': lockerData['lockerCode'],
            'location': lockerData['location'],
            'status': lockerData['status'],
            'currentBalance': 0.0,
            'remainingTimeMinutes': 0,
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing default lockers: $e');
    }
  }

  String _statusToString(LockerStatus status) {
    switch (status) {
      case LockerStatus.available:
        return 'Available';
      case LockerStatus.occupied:
        return 'Occupied';
      case LockerStatus.maintenance:
        return 'Maintenance';
    }
  }
}
