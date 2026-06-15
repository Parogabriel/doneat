import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';
import '../../widgets/impact_chart.dart';
import '../../widgets/responsive_layout.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  String _currentView = 'STATS'; // 'STATS' ou 'RANKING'

  final List<Map<String, dynamic>> _leaderboardMock = [
    {
      'id': '1',
      'name': 'Restaurante Sabor',
      'xp': 4500,
      'avatar': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=200&auto=format&fit=crop'
    },
    {
      'id': '2',
      'name': 'Padaria Central',
      'xp': 3200,
      'avatar': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=200&auto=format&fit=crop'
    },
    {
      'id': '3',
      'name': 'Mercado do Vale',
      'xp': 2800,
      'avatar': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?q=80&w=200&auto=format&fit=crop'
    },
    {
      'id': '4',
      'name': 'Lanchonete 24h',
      'xp': 1900,
      'avatar': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=200&auto=format&fit=crop'
    },
    {
      'id': '5',
      'name': 'Cantina Italiana',
      'xp': 1560,
      'avatar': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=200&auto=format&fit=crop'
    },
  ];

  final List<Map<String, dynamic>> _badgesMock = [
    {'id': '1', 'name': 'Iniciante', 'icon': Icons.star_rounded, 'color': Colors.amber, 'desc': 'Realizou a primeira doação'},
    {'id': '2', 'name': 'Herói Regional', 'icon': Icons.location_on_rounded, 'color': Colors.green, 'desc': 'Doou em 5 bairros diferentes'},
    {'id': '3', 'name': 'Salva Vidas', 'icon': Icons.local_fire_department_rounded, 'color': Colors.orange, 'desc': 'Salvou mais de 100kg de alimentos'},
    {'id': '4', 'name': 'Eco Guerrero', 'icon': Icons.eco_rounded, 'color': Colors.blue, 'desc': 'Evitou 50kg de emissão de CO2'},
    {'id': '5', 'name': 'Mestre Cuca', 'icon': Icons.restaurant_menu_rounded, 'color': Colors.purple, 'desc': 'Doador frequente de refeições'},
    {'id': '6', 'name': 'Legendário', 'icon': Icons.emoji_events_rounded, 'color': const Color(0xFF0F172A), 'desc': 'Top 1% da plataforma'},
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final profile = state.currentProfile;

    // Estatísticas locais mockadas
    final int mealsCount = 342 + (profile != null ? (profile.xp ~/ 10) : 0);
    final double kgSaved = 124.5 + (profile != null ? (profile.xp / 100) : 0.0);
    final double co2Avoided = 248.9 + (profile != null ? (profile.xp / 50) : 0.0);
    final int currentXp = profile?.xp ?? 2850;
    final int currentLevel = profile?.level ?? 2;
    final int nextLevelXp = currentLevel * 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ResponsiveLayout(
          mobileBody: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentView == 'STATS'
                ? _buildStatsView(state, mealsCount, kgSaved, co2Avoided, currentXp, currentLevel, nextLevelXp)
                : _buildRankingView(state),
          ),
          webBody: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentView == 'STATS'
                ? _buildWebStatsView(state, mealsCount, kgSaved, co2Avoided, currentXp, currentLevel, nextLevelXp)
                : _buildWebRankingView(state),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsView(
    AppStateProvider state,
    int meals,
    double kg,
    double co2,
    int xp,
    int level,
    int nextLevel,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('stats_view'),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMPACTO SOCIAL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Veja como suas ações estão mudando o mundo.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Grid de Estatísticas (3 boxes)
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Refeições',
                  value: meals.toString(),
                  icon: Icons.restaurant_rounded,
                  color: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  label: 'Kgs Salvos',
                  value: '${kg.toStringAsFixed(1)}kg',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  label: 'CO2 Evitado',
                  value: '${co2.toStringAsFixed(1)}kg',
                  icon: Icons.eco_rounded,
                  color: const Color(0xFFE1F5FE),
                  iconColor: const Color(0xFF01579B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Gráfico de Histórico
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[100]!,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTÓRICO DE IMPACTO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'ESTA SEMANA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: ImpactChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Gamificação (Nível e Botão de Ranking)
          _buildGamificationCard(level, xp, nextLevel),
        ],
      ),
    );
  }

  Widget _buildGamificationCard(int level, int xp, int nextLevel) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NÍVEL $level',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Text(
                      'Influencer Social',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Você ajudou a alimentar centenas de pessoas com excedentes este mês!',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Progresso do XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP $xp',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'PRÓXIMO NÍVEL: $nextLevel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (xp / nextLevel).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botão Global Ranking
          ElevatedButton(
            onPressed: () => setState(() => _currentView = 'RANKING'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VER RANKING GLOBAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.gps_fixed_rounded, color: Color(0xFF10B981), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatsView(
    AppStateProvider state,
    int meals,
    double kg,
    double co2,
    int xp,
    int level,
    int nextLevel,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('web_stats_view'),
      padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 112.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IMPACTO SOCIAL',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Veja como suas ações estão mudando o mundo.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Layout Lado a Lado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna Esquerda: Estatísticas e Gamificação
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            label: 'Refeições',
                            value: meals.toString(),
                            icon: Icons.restaurant_rounded,
                            color: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            label: 'Kgs Salvos',
                            value: '${kg.toStringAsFixed(1)}kg',
                            icon: Icons.inventory_2_rounded,
                            color: const Color(0xFFE8F5E9),
                            iconColor: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatItem(
                            label: 'CO2 Evitado',
                            value: '${co2.toStringAsFixed(1)}kg',
                            icon: Icons.eco_rounded,
                            color: const Color(0xFFE1F5FE),
                            iconColor: const Color(0xFF01579B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildGamificationCard(level, xp, nextLevel),
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // Coluna Direita: Gráfico Expandido
              Expanded(
                flex: 3,
                child: Container(
                  height: 480,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'HISTÓRICO DE IMPACTO',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'ESTA SEMANA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        child: ImpactChart(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebRankingView(AppStateProvider state) {
    final profile = state.currentProfile;
    final int userXp = profile?.xp ?? 2850;

    return SingleChildScrollView(
       key: const ValueKey('web_ranking_view'),
       padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 112.0, bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentView = 'STATS'),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFF8FAFC), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'HALL DA FAMA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna Esquerda: Podio e Líderes
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildPodium(),
                    const SizedBox(height: 32),
                    ..._leaderboardMock.sublist(3).map((item) {
                      final idx = _leaderboardMock.indexOf(item) + 1;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[50]!,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              idx.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: NetworkImage(item['avatar']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${item['xp']} XP',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.star_rounded, color: Colors.grey[200], size: 18),
                          ],
                        ),
                      );
                    }),
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '24',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF81C784),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VOCÊ (SUA LOJA)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  '$userXp XP',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),

              // Coluna Direita: Suas Conquistas
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[100]!,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SUAS CONQUISTAS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${profile != null ? (profile.badges.length > 6 ? 6 : profile.badges.length) : 4} / 6',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _badgesMock.length,
                        itemBuilder: (context, idx) {
                          final badge = _badgesMock[idx];
                          final hasBadge = profile?.badges.contains(badge['id']) ?? (idx < 4);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(
                              color: hasBadge ? Colors.white : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: hasBadge ? const Color(0xFFF8FAFC) : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: hasBadge
                                  ? [
                                      BoxShadow(
                                        color: Colors.grey[100]!,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: hasBadge ? badge['color'] : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    badge['icon'],
                                    color: hasBadge ? Colors.white : Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  badge['name'].toUpperCase(),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: hasBadge ? const Color(0xFF0F172A) : Colors.grey[300],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingView(AppStateProvider state) {
    final profile = state.currentProfile;
    final int userXp = profile?.xp ?? 2850;

    return SingleChildScrollView(
      key: const ValueKey('ranking_view'),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _currentView = 'STATS'),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFF8FAFC), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'HALL DA FAMA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Pódio
          _buildPodium(),
          const SizedBox(height: 32),

          // Lista de líderes (Resto do Ranking)
          ..._leaderboardMock.sublist(3).map((item) {
            final idx = _leaderboardMock.indexOf(item) + 1;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[50]!,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    idx.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(item['avatar']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${item['xp']} XP',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.star_rounded, color: Colors.grey[200], size: 18),
                ],
              ),
            );
          }),

          // Card do Usuário Destacado
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  '24',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF81C784),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VOCÊ (SUA LOJA)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        '$userXp XP',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),

          // Seção Conquistas (Badges)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SUAS CONQUISTAS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${profile != null ? (profile.badges.length > 6 ? 6 : profile.badges.length) : 4} / 6',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: _badgesMock.length,
                itemBuilder: (context, idx) {
                  final badge = _badgesMock[idx];
                  final hasBadge = profile?.badges.contains(badge['id']) ?? (idx < 4);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: hasBadge ? Colors.white : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: hasBadge ? const Color(0xFFF8FAFC) : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: hasBadge
                          ? [
                              BoxShadow(
                                color: Colors.grey[100]!,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hasBadge ? badge['color'] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            badge['icon'],
                            color: hasBadge ? Colors.white : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'].toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: hasBadge ? const Color(0xFF0F172A) : Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2º lugar
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                    image: DecorationImage(
                      image: NetworkImage(_leaderboardMock[1]['avatar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCBD5E1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 90,
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _leaderboardMock[1]['name'].split(' ')[0].toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '2º',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        // 1º lugar (Centro, maior)
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFBBF24), width: 3),
                    image: DecorationImage(
                      image: NetworkImage(_leaderboardMock[0]['avatar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  top: -12,
                  left: 24,
                  child: Icon(Icons.workspace_premium_rounded, color: Color(0xFFFBBF24), size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _leaderboardMock[0]['name'].split(' ')[0].toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '1º',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        // 3º lugar
        Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDBA74), width: 3),
                    image: DecorationImage(
                      image: NetworkImage(_leaderboardMock[2]['avatar']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDBA74),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 80,
              width: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF7ED),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _leaderboardMock[2]['name'].split(' ')[0].toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFFF97316)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '3º',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFF97316)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.grey[400],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
