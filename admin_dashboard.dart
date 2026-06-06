import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_provider.dart';
import '../../services/transport_service.dart';
import '../../widgets/stat_card.dart';
import '../../utils/app_theme.dart';
import 'admin_records_screen.dart';
import 'admin_clients_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TransportService _service = TransportService();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser!;

    final screens = [
      _buildHome(user),
      const AdminRecordsScreen(),
      const AdminClientsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Transports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Clients',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(user) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Colors.white),
                onPressed: () => context.read<AuthProvider>().signOut(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF0E4D6B)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Transport Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bonjour, ${user.name}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<DashboardStats>(
              future: _service.getDashboardStats(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final s = snap.data!;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vue globale',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          StatCard(
                            title: 'Total Livraisons',
                            value: '${s.totalDeliveries}',
                            icon: Icons.local_shipping_outlined,
                            color: AppColors.secondary,
                          ),
                          StatCard(
                            title: 'Total Clients',
                            value: '${s.totalClients}',
                            icon: Icons.business_outlined,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            title: 'Consommation Totale',
                            value: '${s.totalFuelConsumption.toStringAsFixed(0)}L',
                            icon: Icons.local_gas_station_outlined,
                            color: AppColors.success,
                          ),
                          StatCard(
                            title: 'Bons en attente',
                            value: '${s.pendingVouchers}',
                            icon: Icons.receipt_long_outlined,
                            color: AppColors.warning,
                            isHighlighted: s.pendingVouchers > 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StatCard(
                        title: 'Palettes en attente',
                        value: '${s.pendingPalettes}',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.accent,
                        isHighlighted: s.pendingPalettes > 0,
                        subtitle: 'palettes non rendues',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transports récents',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: _service.streamAllRecords(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()));
              }
              final records = snap.data!.take(3).toList();
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final r = records[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.local_shipping_outlined,
                                color: AppColors.secondary),
                          ),
                          title: Text(r.destination,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${r.client} • ${r.driverName}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(DateFormat('dd/MM').format(r.date),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                              Text('${r.fuelConsumption.toStringAsFixed(0)}L',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondary)),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: records.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
