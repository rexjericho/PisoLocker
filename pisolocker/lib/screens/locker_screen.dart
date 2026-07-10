import 'package:flutter/material.dart';
import '../models/locker.dart';
import '../widgets/locker_card.dart';
import '../widgets/coin_insertion_dialog.dart';

/// Locker Screen - Monitor available lockers and rent them
/// Users can view all lockers, see their status, and rent available ones
/// by inserting Piso coins (1 Piso = 20 minutes)
class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> with TickerProviderStateMixin {
  // List of lockers - easily extensible
  final List<Locker> _lockers = [
    const Locker(
      id: 'L-001',
      name: 'Locker 1',
      isAvailable: true,
      isOccupied: false,
      location: 'Ground Floor - Near Entrance',
    ),
    const Locker(
      id: 'L-002',
      name: 'Locker 2',
      isAvailable: true,
      isOccupied: false,
      location: 'Ground Floor - Near Entrance',
    ),
    // Add more lockers here as needed
    // const Locker(
    //   id: 'L-003',
    //   name: 'Locker 3',
    //   isAvailable: true,
    //   isOccupied: false,
    //   location: 'Second Floor - Near Elevator',
    // ),
  ];

  int _selectedIndex = 1; // Rent Locker tab selected

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate based on selection
    if (index == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
    // Add more navigation logic for other tabs
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
      
      // Update locker status (in real app, this would come from backend/IoT)
      setState(() {
        final index = _lockers.indexWhere((l) => l.id == locker.id);
        if (index != -1) {
          _lockers[index] = locker.copyWith(
            isAvailable: false,
            isOccupied: true,
            currentBalance: coins.toDouble(),
            remainingTime: time,
          );
        }
      });
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
    final availableCount = _lockers.where((l) => l.isAvailable && !l.isOccupied).length;
    final occupiedCount = _lockers.length - availableCount;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'PisoLocker',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
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
                itemCount: _lockers.length,
                itemBuilder: (context, index) {
                  final locker = _lockers[index];
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
