/// Model representing a locker in the PisoLocker system
class Locker {
  final String id;
  final String name;
  final bool isAvailable;
  final bool isOccupied;
  final double? currentBalance; // in Piso
  final Duration? remainingTime;
  final String? location;

  const Locker({
    required this.id,
    required this.name,
    this.isAvailable = true,
    this.isOccupied = false,
    this.currentBalance,
    this.remainingTime,
    this.location,
  });

  Locker copyWith({
    String? id,
    String? name,
    bool? isAvailable,
    bool? isOccupied,
    double? currentBalance,
    Duration? remainingTime,
    String? location,
  }) {
    return Locker(
      id: id ?? this.id,
      name: name ?? this.name,
      isAvailable: isAvailable ?? this.isAvailable,
      isOccupied: isOccupied ?? this.isOccupied,
      currentBalance: currentBalance ?? this.currentBalance,
      remainingTime: remainingTime ?? this.remainingTime,
      location: location ?? this.location,
    );
  }
}
