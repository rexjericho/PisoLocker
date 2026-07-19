import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/locker.dart';

/// Reusable card widget for displaying locker information
class LockerCard extends StatelessWidget {
  final Locker locker;
  final VoidCallback? onRentTap;
  final VoidCallback? onViewDetailsTap;

  const LockerCard({
    super.key,
    required this.locker,
    this.onRentTap,
    this.onViewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = locker.isAvailable && !locker.isOccupied;
    final isMaintenance = locker.isMaintenance;

    return Card(
      elevation: 2,
      shadowColor: isAvailable 
          ? theme.colorScheme.primary.withValues(alpha: 0.3)
          : isMaintenance
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAvailable 
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : isMaintenance
                  ? Colors.orange.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isAvailable || isMaintenance ? null : onViewDetailsTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with locker ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAvailable 
                              ? theme.colorScheme.primaryContainer
                              : isMaintenance
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isAvailable 
                              ? Icons.lock_open 
                              : isMaintenance 
                                  ? Icons.build 
                                  : Icons.lock,
                          color: isAvailable 
                              ? theme.colorScheme.onPrimaryContainer
                              : isMaintenance
                                  ? Colors.orange.shade700
                                  : theme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locker.lockerCode,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            locker.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(isAvailable, isMaintenance, theme),
                ],
              ),

              const SizedBox(height: 16),

              // Location (if available)
              if (locker.location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locker.location!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Current rental info (if occupied) - Show rentalEndTime instead of remaining time
              if (!isAvailable && !isMaintenance && locker.rentalEndTime != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: theme.colorScheme.onTertiaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Until: ${DateFormat('h:mm a').format(locker.rentalEndTime!.toDate())}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action button
              if (isAvailable)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onRentTap,
                    icon: const Icon(Icons.add),
                    label: const Text('Rent Locker'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else if (isMaintenance)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: null, // Disabled during maintenance
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade700),
                    ),
                    child: const Text('Under Maintenance'),
                  ),
                )
              else if (!isAvailable && locker.isOccupied)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onViewDetailsTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isAvailable, bool isMaintenance, ThemeData theme) {
    String statusText;
    Color bgColor;
    Color textColor;
    
    if (isMaintenance) {
      statusText = 'Maintenance';
      bgColor = Colors.orange.withValues(alpha: 0.2);
      textColor = Colors.orange.shade700;
    } else if (isAvailable) {
      statusText = 'Available';
      bgColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
    } else {
      statusText = 'Occupied';
      bgColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
