import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/app_state_provider.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final currentPage = state.currentPage;
    final role = state.currentProfile?.role;

    // Se o usuário não estiver logado ou estiver no onboarding, não renderiza nav
    if (state.currentProfile == null || role == null) {
      return const SizedBox.shrink();
    }

    final tabs = [
      {'id': 'HOME', 'icon': Icons.home_rounded, 'label': 'Início'},
      {'id': 'DASHBOARD', 'icon': Icons.dashboard_rounded, 'label': 'Painel'},
      {'id': 'TRACKING', 'icon': Icons.map_rounded, 'label': 'Mapa'},
      {'id': 'PROFILE', 'icon': Icons.person_rounded, 'label': 'Perfil'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tabs.map((tab) {
                final id = tab['id'] as String;
                final icon = tab['icon'] as IconData;
                final isActive = currentPage == id;

                // Cria um espaço no meio se for doador para não sobrepor o botão flutuante
                if (role == UserRole.donor && id == 'TRACKING') {
                  return const SizedBox(width: 48);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => state.setCurrentPage(id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            icon,
                            color: isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[300],
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 4 : 0,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Botão central flutuante para Doadores
            if (role == UserRole.donor)
              Positioned(
                bottom: 12,
                child: GestureDetector(
                  onTap: () => state.setCurrentPage('DONATE'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: currentPage == 'DONATE'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: currentPage == 'DONATE'
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                              : const Color(0xFF0F172A).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
