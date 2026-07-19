import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Enum representing the status of a locker
enum LockerStatus { available, occupied, maintenance }

/// Model representing a locker in the PisoLocker system
class Locker {
  final String id;
  final String lockerCode;
  final LockerStatus status;
  final String? location;
  final double? currentBalance; // in Piso
  final Duration? remainingTime;
  final String? rentedBy; // UID of user who rented it
  final Timestamp? rentalEndTime;
  final String lockStatus; // 'Locked' or 'Unlocked'
  final String? otp;

  const Locker({
    required this.id,
    required this.lockerCode,
    this.status = LockerStatus.available,
    this.location,
    this.currentBalance,
    this.remainingTime,
    this.rentedBy,
    this.rentalEndTime,
    this.lockStatus = 'Unlocked',
    this.otp,
  });

  bool get isAvailable => status == LockerStatus.available;
  bool get isOccupied => status == LockerStatus.occupied;
  bool get isMaintenance => status == LockerStatus.maintenance;
  bool get isLocked => lockStatus == 'Locked';

  /// Format rental end time for display
  String get formattedRentalEndTime {
    if (rentalEndTime == null) return '';
    return DateFormat('h:mm a').format(rentalEndTime!.toDate());
  }

  /// Create a Locker from Firestore document
  factory Locker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Locker(
      id: doc.id,
      lockerCode: data['lockerCode'] ?? 'Locker ${doc.id}',
      status: _parseStatus(data['status']),
      location: data['location'],
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      remainingTime: data['remainingTimeMinutes'] != null 
          ? Duration(minutes: data['remainingTimeMinutes']) 
          : null,
      rentedBy: data['rentedBy'],
      rentalEndTime: data['rentalEndTime'],
      lockStatus: data['lockStatus'] ?? 'Unlocked',
      otp: data['otp'],
    );
  }

  /// Convert Locker to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'lockerCode': lockerCode,
      'status': _statusToString(status),
      'location': location,
      'currentBalance': currentBalance ?? 0.0,
      'remainingTimeMinutes': remainingTime?.inMinutes,
      'rentedBy': rentedBy,
      'rentalEndTime': rentalEndTime,
      'lockStatus': lockStatus,
      'otp': otp,
    };
  }

  static LockerStatus _parseStatus(dynamic status) {
    if (status == null) return LockerStatus.available;
    if (status is int) return LockerStatus.values[status];
    switch (status.toString().toLowerCase()) {
      case 'available':
        return LockerStatus.available;
      case 'occupied':
        return LockerStatus.occupied;
      case 'maintenance':
        return LockerStatus.maintenance;
      default:
        return LockerStatus.available;
    }
  }

  static String _statusToString(LockerStatus status) {
    switch (status) {
      case LockerStatus.available:
        return 'Available';
      case LockerStatus.occupied:
        return 'Occupied';
      case LockerStatus.maintenance:
        return 'Maintenance';
    }
  }

  Locker copyWith({
    String? id,
    String? lockerCode,
    LockerStatus? status,
    String? location,
    double? currentBalance,
    Duration? remainingTime,
    String? rentedBy,
    Timestamp? rentalEndTime,
    String? lockStatus,
    String? otp,
  }) {
    return Locker(
      id: id ?? this.id,
      lockerCode: lockerCode ?? this.lockerCode,
      status: status ?? this.status,
      location: location ?? this.location,
      currentBalance: currentBalance ?? this.currentBalance,
      remainingTime: remainingTime ?? this.remainingTime,
      rentedBy: rentedBy ?? this.rentedBy,
      rentalEndTime: rentalEndTime ?? this.rentalEndTime,
      lockStatus: lockStatus ?? this.lockStatus,
      otp: otp ?? this.otp,
    );
  }
}
