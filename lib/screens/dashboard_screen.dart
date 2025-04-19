import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String title;
  final String userRole;
  final List<DashboardTile> tiles;

  const DashboardScreen({
    super.key,
    required this.title,
    required this.userRole,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userRole!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12, runSpacing: 12,
                  children: tiles.map((tile) => _buildCard(context, tile)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, DashboardTile tile) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: tile.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tile.icon, size: 36, color: Colors.indigo),
                const SizedBox(height: 8),
                Text(
                  tile.label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardTile {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  DashboardTile({required this.icon, required this.label, required this.onTap});
}
