import 'package:flutter/material.dart';
import '../models/locker.dart';

/// Dialog for inserting Piso coins to rent a locker
/// Each Piso = 20 minutes of rental time
/// User has 5 minutes to insert coins before timeout
class CoinInsertionDialog extends StatefulWidget {
  final Locker locker;
  final Function(int coinsInserted, Duration timeAdded) onConfirm;

  const CoinInsertionDialog({
    super.key,
    required this.locker,
    required this.onConfirm,
  });

  @override
  State<CoinInsertionDialog> createState() => _CoinInsertionDialogState();
}

class _CoinInsertionDialogState extends State<CoinInsertionDialog>
    with SingleTickerProviderStateMixin {
  int _coinsInserted = 0;
  int _timeRemaining = 300; // 5 minutes in seconds
  bool _isTimedOut = false;
  
  static const int secondsPerPiso = 20 * 60; // 20 minutes per Piso
  
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Timer ticks every second, decrementing the counter
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      
      if (_timeRemaining > 0 && !_isTimedOut) {
        setState(() {
          _timeRemaining--;
        });
        return true;
      } else if (_timeRemaining <= 0 && !_isTimedOut) {
        setState(() {
          _isTimedOut = true;
        });
        return false;
      }
      return false;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Duration _calculateTotalTime() {
    return Duration(seconds: _coinsInserted * secondsPerPiso);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  void _simulateCoinInsert() {
    if (_isTimedOut) return;
    
    setState(() {
      _coinsInserted++;
      // Reset timer on each coin insertion (optional - can be removed if not desired)
      // _timeRemaining = 300;
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDuration = _calculateTotalTime();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Insert Coins',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              widget.locker.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Coin slot visualization
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Coin slot icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Simulated insert button (for demo purposes)
                  ElevatedButton.icon(
                    onPressed: _isTimedOut ? null : _simulateCoinInsert,
                    icon: const Icon(Icons.add),
                    label: const Text('Insert 1 Piso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  Text(
                    '(Simulates coin insertion)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats display
            Row(
              children: [
                // Coins inserted
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.money,
                    label: 'Coins Inserted',
                    value: '$_coinsInserted Piso',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                // Time earned
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    label: 'Time Earned',
                    value: _formatDuration(totalDuration),
                    theme: theme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timer display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isTimedOut 
                    ? theme.colorScheme.errorContainer 
                    : _timeRemaining < 60 
                        ? theme.colorScheme.tertiaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isTimedOut ? Icons.timer_off : Icons.timer_outlined,
                    color: _isTimedOut 
                        ? theme.colorScheme.onErrorContainer 
                        : _timeRemaining < 60 
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isTimedOut 
                        ? 'Time\'s up! Please confirm or cancel.'
                        : 'Time remaining to insert coins: ${_formatTime(_timeRemaining)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isTimedOut 
                          ? theme.colorScheme.onErrorContainer 
                          : _timeRemaining < 60 
                              ? theme.colorScheme.onTertiaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _coinsInserted == 0 || _isTimedOut
                        ? null
                        : () {
                            widget.onConfirm(
                              _coinsInserted,
                              totalDuration,
                            );
                            Navigator.of(context).pop();
                          },
                    icon: const Icon(Icons.check),
                    label: Text('Confirm ($_coinsInserted Piso)'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
