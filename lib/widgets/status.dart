import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.redAccent;
      case 'waiting_approval':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (small) {
      // ✅ small circle for lists
      return Container(
        margin: const EdgeInsets.only(right: 8),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _getStatusColor(),
          shape: BoxShape.circle,
        ),
      );
    }

    // ✅ floating FAB for dashboards
    return Positioned(
      top: 30,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: null,
        onPressed: () {},
        backgroundColor: _getStatusColor(),
        child: const Icon(Icons.circle, size: 14, color: Colors.white),
      ),
    );
  }
}
