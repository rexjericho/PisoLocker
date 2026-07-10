import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final String _lockerId = 'L-2047';
  final String _otp = '837492';
  final Duration _rentalDuration = const Duration(hours: 2);
  DateTime? _rentalStartTime;
  late AnimationController _lockAnimationController;
  late AnimationController _unlockAnimationController;
  late Animation<double> _lockScaleAnimation;
  late Animation<double> _unlockScaleAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _rentalStartTime = DateTime.now();

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
      setState(() => _isAnimating = false);
    }
  }

  Future<void> _handleUnlock() async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    await _unlockAnimationController.forward();
    await _unlockAnimationController.reverse();

    if (mounted) {
      _showActionDialog(context, 'Unlock Locker', 'Are you sure you want to unlock this locker?');
      setState(() => _isAnimating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Locker ID Label
              _buildInfoCard(
                label: 'Locker ID',
                value: _lockerId,
                icon: Icons.storage,
              ),
              const SizedBox(height: 16),
              // OTP Label
              _buildInfoCard(
                label: 'Your OTP',
                value: _otp,
                icon: Icons.password,
                isOtp: true,
              ),
              const SizedBox(height: 16),
              // Time Remaining Label
              _buildTimeRemainingCard(),
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
  }) {
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
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
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
            value,
            style: TextStyle(
              fontSize: isOtp ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: isOtp ? 4 : 0,
            ),
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
    if (_rentalStartTime == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_rentalStartTime!);
    final remaining = _rentalDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
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
