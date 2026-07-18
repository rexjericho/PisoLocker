import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/locker.dart';
import '../widgets/locker_card.dart';
import '../widgets/coin_insertion_dialog.dart';
import '../providers/locker_provider.dart';

/// Locker Screen - Monitor available lockers and rent them
/// Users can view all lockers, see their status, and rent available ones
/// by inserting Piso coins (1 Piso = 20 minutes)
class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> with TickerProviderStateMixin {
  int _selectedIndex = 1; // Rent Locker tab selected
  
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  List<Locker> _getLockers(LockerProvider provider) {
    return [
      Locker(
        id: 'L-001',
        name: 'Locker 1',
        isAvailable: !provider.isLockerRented('L-001'),
        isOccupied: provider.isLockerRented('L-001'),
        location: 'Ground Floor - Near Entrance',
        currentBalance: provider.isLockerRented('L-001') ? 1.0 : null,
        remainingTime: provider.isRentalActive() && provider.rentedLockerId == 'L-001' 
            ? provider.rentalEndTime?.difference(DateTime.now()) ?? Duration.zero 
            : null,
      ),
      Locker(
        id: 'L-002',
        name: 'Locker 2',
        isAvailable: !provider.isLockerRented('L-002'),
        isOccupied: provider.isLockerRented('L-002'),
        location: 'Ground Floor - Near Entrance',
        currentBalance: provider.isLockerRented('L-002') ? 1.0 : null,
        remainingTime: provider.isRentalActive() && provider.rentedLockerId == 'L-002' 
            ? provider.rentalEndTime?.difference(DateTime.now()) ?? Duration.zero 
            : null,
      ),
    ];
  }

  void _onBottomNavTap(int index) {
    // Navigate based on selection
    if (index == 0 && _selectedIndex != 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (index == 1 && _selectedIndex != 1) {
      // Already on locker screen, do nothing
      return;
    } else if (index == 2 && _selectedIndex != 2) {
      Navigator.of(context).pushNamedAndRemoveUntil('/faq', (route) => false);
    } else if (index == 3 && _selectedIndex != 3) {
      Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleRentLocker(Locker locker) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CoinInsertionDialog(
          locker: locker,
          onConfirm: (coinsInserted, timeAdded) {
            _processRental(locker, coinsInserted, timeAdded);
          },
        );
      },
    );
  }

  void _processRental(Locker locker, int coins, Duration time) {
    final provider = Provider.of<LockerProvider>(context, listen: false);
    
    // TODO: Integrate with IoT hardware to:
    // 1. Verify coin insertion via hardware sensor
    // 2. Lock the locker
    // 3. Start the timer
    // 4. Update backend with rental information
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully rented ${locker.name} for $coins Piso (${_formatDuration(time)})'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Calculate rental end time
      final rentalEndTime = DateTime.now().add(time);
      
      // Update provider with rental data
      provider.rentLocker(
        lockerId: locker.id,
        otp: '837492', // Generate or fetch actual OTP
        location: locker.location ?? 'Unknown',
        rentalEndTime: rentalEndTime,
        totalRentalDuration: time,
      );
      
      // Navigate to home screen
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _viewLockerDetails(Locker locker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Text(
                locker.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                locker.id,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (locker.location != null) ...[
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: locker.location!,
                ),
                const SizedBox(height: 16),
              ],
              
              _buildDetailRow(
                icon: locker.isAvailable ? Icons.check_circle : Icons.cancel,
                label: 'Status',
                value: locker.isAvailable ? 'Available' : 'Occupied',
                valueColor: locker.isAvailable 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.error,
              ),
              
              if (!locker.isAvailable && locker.remainingTime != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.timer,
                  label: 'Time Remaining',
                  value: _formatDuration(locker.remainingTime!),
                ),
              ],
              
              if (!locker.isAvailable && locker.currentBalance != null) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.money,
                  label: 'Current Balance',
                  value: '${locker.currentBalance!.toStringAsFixed(0)} Piso',
                ),
              ],
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LockerProvider>(context);
    final lockers = _getLockers(provider);
    final availableCount = lockers.where((l) => l.isAvailable && !l.isOccupied).length;
    final occupiedCount = lockers.length - availableCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PisoLocker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Locker Management',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showSignOutDialog(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Available Lockers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Select a locker to rent. Insert Piso coins to add time.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.lock_open,
                      label: 'Available',
                      value: availableCount.toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.lock,
                      label: 'Occupied',
                      value: occupiedCount.toString(),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Info card about pricing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How it works',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '1 Piso = 20 minutes\nYou have 5 minutes to insert coins',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Locker list
              Text(
                'Lockers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // List of lockers
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lockers.length,
                itemBuilder: (context, index) {
                  final locker = lockers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LockerCard(
                      locker: locker,
                      onRentTap: () => _handleRentLocker(locker),
                      onViewDetailsTap: () => _viewLockerDetails(locker),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onBottomNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.storage_outlined),
            selectedIcon: Icon(Icons.storage),
            label: 'Rent Locker',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'FAQ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
