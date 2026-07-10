import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  final bool hasRentedLocker;
  final String? lockerId;
  final String? otp;
  final String? location;
  final DateTime? rentalEndTime;
  final Duration? totalRentalDuration;

  const HomeScreen({
    super.key, 
    this.userName, 
    this.hasRentedLocker = true,
    this.lockerId,
    this.otp,
    this.location,
    this.rentalEndTime,
    this.totalRentalDuration,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _lockAnimationController;
  late AnimationController _unlockAnimationController;
  late Animation<double> _lockScaleAnimation;
  late Animation<double> _unlockScaleAnimation;
  bool _isAnimating = false;
  bool _isLocked = false; // Track locker status

  @override
  void initState() {
    super.initState();

    // Lock button animation
    _lockAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _lockScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _lockAnimationController, curve: Curves.easeInOut),
    );

    // Unlock button animation
    _unlockAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _unlockScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _unlockAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lockAnimationController.dispose();
    _unlockAnimationController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate based on selection
    if (index == 1) {
      Navigator.of(context).pushNamedAndRemoveUntil('/locker', (route) => false);
    }
    // Add more navigation logic for other tabs (FAQ, Profile) as needed
  }

  Future<void> _handleLock() async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    await _lockAnimationController.forward();
    await _lockAnimationController.reverse();

    if (mounted) {
      _showActionDialog(context, 'Lock Locker', 'Are you sure you want to lock this locker?');
      setState(() {
        _isAnimating = false;
        _isLocked = true;
      });
    }
  }

  Future<void> _handleUnlock() async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    await _unlockAnimationController.forward();
    await _unlockAnimationController.reverse();

    if (mounted) {
      _showActionDialog(context, 'Unlock Locker', 'Are you sure you want to unlock this locker?');
      setState(() {
        _isAnimating = false;
        _isLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show overlay if user hasn't rented a locker
    if (!widget.hasRentedLocker) {
      return Scaffold(
        body: Stack(
          children: [
            // Background content (blurred or dimmed)
            Opacity(
              opacity: 0.3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 100, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No Active Rental',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Overlay directing to rent locker
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Locker Rented Yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Please rent a locker to access this screen',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil('/locker', (route) => false);
                            },
                            icon: const Icon(Icons.storage),
                            label: const Text('Rent a Locker'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo placeholder - replace with your actual logo asset
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PisoLocker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (widget.userName != null)
                  Text(
                    'Welcome, ${widget.userName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Locker Status Indicator
              _buildLockerStatusCard(),
              const SizedBox(height: 16),
              // Locker ID Label (smaller)
              _buildInfoCard(
                label: 'Locker ID',
                value: widget.lockerId ?? 'N/A',
                icon: Icons.storage,
                isSmall: true,
              ),
              const SizedBox(height: 16),
              // OTP Label (smaller)
              _buildInfoCard(
                label: 'Your OTP',
                value: widget.otp ?? 'N/A',
                icon: Icons.password,
                isOtp: true,
                isSmall: true,
              ),
              const SizedBox(height: 16),
              // Location Label
              _buildInfoCard(
                label: 'Location',
                value: widget.location ?? 'N/A',
                icon: Icons.location_on,
                isSmall: true,
              ),
              const SizedBox(height: 16),
              // Time Remaining Label
              _buildTimeRemainingCard(),
              const SizedBox(height: 16),
              // Rental Expiration Time Label
              _buildExpirationTimeCard(),
              const SizedBox(height: 32),
              // Lock Button
              AnimatedBuilder(
                animation: _lockScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _lockScaleAnimation.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: ElevatedButton.icon(
                    onPressed: _handleLock,
                    icon: const Icon(Icons.lock, size: 32),
                    label: const Text(
                      'LOCK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Unlock Button
              AnimatedBuilder(
                animation: _unlockScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _unlockScaleAnimation.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: ElevatedButton.icon(
                    onPressed: _handleUnlock,
                    icon: const Icon(Icons.lock_open, size: 32),
                    label: const Text(
                      'UNLOCK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // End Session Button
              OutlinedButton.icon(
                onPressed: () {
                  _showEndSessionDialog(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('End Session'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
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

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    bool isOtp = false,
    bool isSmall = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isSmall ? 16 : 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? (isOtp ? 20 : 16) : (isOtp ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: isOtp ? 4 : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockerStatusCard() {
    final statusColor = _isLocked 
        ? Theme.of(context).colorScheme.error 
        : Theme.of(context).colorScheme.primary;
    final statusIcon = _isLocked ? Icons.lock : Icons.lock_open;
    final statusText = _isLocked ? 'LOCKED' : 'UNLOCKED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: 0.2),
            statusColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            statusIcon,
            size: 32,
            color: statusColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Locker Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final remaining = _calculateTimeRemaining();
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes.remainder(60);
        final seconds = remaining.inSeconds.remainder(60);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time Remaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeSegment(hours.toString().padLeft(2, '0'), 'HR'),
                  const SizedBox(width: 8),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeSegment(minutes.toString().padLeft(2, '0'), 'MIN'),
                  const SizedBox(width: 8),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeSegment(seconds.toString().padLeft(2, '0'), 'SEC'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSegment(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Duration _calculateTimeRemaining() {
    if (widget.rentalEndTime == null) return Duration.zero;
    final remaining = widget.rentalEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Widget _buildExpirationTimeCard() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final expirationTime = widget.rentalEndTime;
        final currentTime = DateTime.now();
        
        if (expirationTime == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rental Expires At',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'N/A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        final isExpired = expirationTime.isBefore(currentTime);
        final statusColor = isExpired 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.2),
                statusColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 20,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rental Expires At',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exact Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(expirationTime),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(currentTime),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isExpired) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rental time has expired!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  void _showActionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Add actual lock/unlock logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title action initiated')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showEndSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'),
          content: const Text('Are you sure you want to end your current session?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );
  }
}
