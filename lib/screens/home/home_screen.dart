import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_constants.dart';
import '../../models/donation.dart';
import '../../models/user.dart';
import '../../services/app_state_provider.dart';
import '../../widgets/donation_card.dart';
import '../../widgets/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeCategory = 'All';
  Donation? _selectedMapDonation;
  bool _showMapOnMobile = false;
  bool _showAllEstablishments = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final role = state.currentProfile?.role;

    final filteredEstablishments = AppConstants.establishments.where((est) {
      final matchesSearch = est.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          est.categoria.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          est.especialidade.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _activeCategory == 'All' || est.categoria == _activeCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Glow Orbs (Radial Light Leaks)
          const GlowOrb(top: -100, left: -100, size: 400, color: Color(0xFF6366F1)), // Indigo
          const GlowOrb(bottom: -150, right: -150, size: 500, color: Color(0xFF10B981)), // Emerald
          const GlowOrb(top: 250, right: 100, size: 350, color: Color(0xFFEC4899)), // Pink

          ResponsiveLayout(
            mobileBody: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_showAllEstablishments),
                child: _showAllEstablishments
                    ? _buildAllEstablishmentsGrid(filteredEstablishments)
                    : _buildMobileLayout(state, role, filteredEstablishments),
              ),
            ),
            webBody: _buildWebLayout(state, role, filteredEstablishments),
          ),
        ],
      ),
    );
  }

  // --- LAYOUT WEB / DESKTOP (FULL-SCREEN SITE) ---
  Widget _buildWebLayout(
    AppStateProvider state,
    UserRole? role,
    List<Establishment> establishments,
  ) {
    return SafeArea(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 104.0, bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top header specific to Home web
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OLÁ, PARCEIRO!',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        state.currentProfile?.businessName ?? 'Carregando...',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 350,
                    child: _buildSearchBar(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Amplo Banner Promocional
              _buildWebHeroBanner(state),
              const SizedBox(height: 40),

              // Categorias
              const Text(
                'CATEGORIAS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryFilters(),
              const SizedBox(height: 40),

              // Active donations section (if receiver)
              if (role == UserRole.receiver) ...[
                _buildActiveDonationsSection(state),
                const SizedBox(height: 40),
              ],

              // Grid adaptável de parceiros/estabelecimentos
              const Text(
                'ESTABELECIMENTOS PARCEIROS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Adaptive GridView
              LayoutBuilder(
                builder: (context, gridConstraints) {
                  final width = gridConstraints.maxWidth;
                  final crossAxisCount = width > 1200 ? 4 : 3;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: establishments.length,
                    itemBuilder: (context, index) {
                      final est = establishments[index];
                      return FadeInSlideUp(
                        delay: Duration(milliseconds: index * 40),
                        child: HoverScaleContainer(
                          onTap: () => _showEstablishmentDetailsDialog(context, est),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                    child: Image.network(
                                      est.imagem,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        est.categoria.toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        est.nome,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        est.especialidade,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            est.avaliacao.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${est.tempoEntregaMinutos} min • Frete R\$ ${est.frete.toStringAsFixed(2)}',
                                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeroBanner(AppStateProvider state) {
    return HoverScaleContainer(
      onTap: () => state.setCurrentPage('DONATE'),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=1200&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A).withValues(alpha: 0.8),
                        const Color(0xFF10B981).withValues(alpha: 0.5),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'AJUDE A DIMINUIR O DESPERDÍCIO DE COMIDA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compartilhe refeições excedentes com quem precisa e acumule pontos de impacto social.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => state.setCurrentPage('DONATE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text(
                        'DOAR AGORA',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LAYOUT MOBILE ---
  Widget _buildMobileLayout(
    AppStateProvider state,
    UserRole? role,
    List<Establishment> establishments,
  ) {
    return Stack(
      children: [
        if (_showMapOnMobile)
          Positioned.fill(
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildInteractiveMap(state)),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: HoverScaleContainer(
                      onTap: () => setState(() => _showMapOnMobile = false),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                  if (_selectedMapDonation != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: _buildSelectedDonationOverlay(),
                    ),
                ],
              ),
            ),
          )
        else
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildCategoryFilters(),
                  const SizedBox(height: 32),
                  _buildHeroBanner(state),
                  const SizedBox(height: 32),
                  if (role == UserRole.receiver) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DOAÇÕES ATIVAS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _showMapOnMobile = true;
                            _selectedMapDonation = null;
                          }),
                          icon: const Icon(Icons.map_rounded, size: 14),
                          label: const Text('VER NO MAPA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActiveDonationsSection(state),
                    const SizedBox(height: 32),
                  ],
                  _buildEstablishmentsTitleSection(),
                  const SizedBox(height: 16),
                  _buildNearStoresSection(establishments),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --- TELA DE PARCEIROS EM GRADE (GRID VIEW) ---
  Widget _buildAllEstablishmentsGrid(List<Establishment> establishments) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                HoverScaleContainer(
                  onTap: () => setState(() => _showAllEstablishments = false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'PARCEIROS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 120),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: establishments.length,
                itemBuilder: (context, index) {
                  final est = establishments[index];
                  return FadeInSlideUp(
                    delay: Duration(milliseconds: index * 40),
                    child: HoverScaleContainer(
                      onTap: () => _showEstablishmentDetailsDialog(context, est),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                child: Image.network(
                                  est.imagem,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    est.categoria.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    est.nome,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    est.especialidade,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white38, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    ),
  );
}

  // --- SUB-WIDGETS COMPARTILHADOS ---
  Widget _buildHeader(AppStateProvider state) {
    final name = state.currentProfile?.displayName ?? 'Carlos';
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w900, 
              color: Color(0xFF10B981),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OLÁ, $name'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${state.currentProfile?.xp ?? 0} XP acumulados',
                style: const TextStyle(
                  color: Colors.white54, 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        HoverScaleContainer(
          onTap: () => Scaffold.of(context).openEndDrawer(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.notifications_none_rounded, 
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        controller: _searchController,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          hintText: 'Buscar restaurantes ou categorias...',
          hintStyle: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF10B981), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Refeições', 'Salgados', 'Doces', 'Bebidas', 'In Natura'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _activeCategory == cat;
          return HoverScaleContainer(
            onTap: () => setState(() => _activeCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                cat.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.white : Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(AppStateProvider state) {
    return HoverScaleContainer(
      onTap: () => state.setCurrentPage('DONATE'),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A).withValues(alpha: 0.85),
                        const Color(0xFF10B981).withValues(alpha: 0.7),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'AJUDE A DIMINUIR\nO DESPERDÍCIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Doe alimentos excedentes hoje e receba benefícios.',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'QUERO DOAR AGORA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDonationsSection(AppStateProvider state) {
    if (state.activeDonations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.currentPage != 'HOME')
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'ALIMENTOS DISPONÍVEIS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(state.activeDonations.length, (idx) {
            final donation = state.activeDonations[idx];
            return FadeInSlideUp(
              delay: Duration(milliseconds: idx * 60),
              child: DonationCard(donation: donation),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEstablishmentsTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ESTABELECIMENTOS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        HoverScaleContainer(
          onTap: () => setState(() => _showAllEstablishments = true),
          child: const Row(
            children: [
              Text(
                'VER TODOS',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF10B981)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNearStoresSection(List<Establishment> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
            ),
            child: const Column(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.white24, size: 48),
                SizedBox(height: 12),
                Text(
                  'NADA ENCONTRADO!',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
                SizedBox(height: 4),
                Text(
                  'Tente alterar os filtros de busca.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          )
        else
          ...List.generate(list.length, (idx) {
            final est = list[idx];
            return FadeInSlideUp(
              delay: Duration(milliseconds: idx * 50),
              child: HoverScaleContainer(
                onTap: () => _showEstablishmentDetailsDialog(context, est),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(est.imagem),
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
                              est.categoria.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              est.nome,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              est.especialidade,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showEstablishmentDetailsDialog(BuildContext context, Establishment est) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        est.nome.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white60),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      est.imagem,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  est.categoria.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  est.especialidade,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'COMPROMISSO CONTRA O DESPERDÍCIO:\n'
                  'Como parceiro certificado do Doneat, ${est.nome} se compromete diariamente a embalar de forma higiênica e segura todo o seu excedente produtivo. Apoiamos integralmente o combate ao desperdício de alimentos na comunidade, garantindo que ingredientes de altíssima qualidade cheguem a quem mais precisa com dignidade e afeto.',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'APOIAR PARCEIRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MOTOR GRÁFICO: MAPA INTERATIVO CUSTOMIZADO (60 FPS) ---
  Widget _buildInteractiveMap(AppStateProvider state) {
    return Container(
      color: const Color(0xFF070A13), // Deep cosmic background
      child: Stack(
        children: [
          // Textura ou Imagem de Fundo Estilizada de Mapa Urbano
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1200&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Pinos Interativos das Doações
          ...state.activeDonations.map((d) {
            final double topFactor = 0.4 + (d.location.lat + 23.55) * 10;
            final double leftFactor = 0.5 + (d.location.lng + 46.66) * 10;

            final isSelected = _selectedMapDonation?.id == d.id;

            return Positioned(
              top: 350 * topFactor,
              left: 450 * leftFactor,
              child: PulsingMapPin(
                donation: d,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedMapDonation = d),
              ),
            );
          }),
        ],
      ),
    );
  }



  Widget _buildSelectedDonationOverlay() {
    final d = _selectedMapDonation!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(
                      d.image ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=200&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      d.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.location.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${d.quantity} ${d.unit.toUpperCase()} DISPONÍVEIS',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              HoverScaleContainer(
                onTap: () => setState(() => _selectedMapDonation = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET AUXILIAR: PULSING MAP PIN (REPENTBOUNDARY ISOLATED) ---
class PulsingMapPin extends StatefulWidget {
  final Donation donation;
  final bool isSelected;
  final VoidCallback onTap;

  const PulsingMapPin({
    super.key,
    required this.donation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PulsingMapPin> createState() => _PulsingMapPinState();
}

class _PulsingMapPinState extends State<PulsingMapPin> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 48 * _pulseController.value,
                    height: 48 * _pulseController.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withValues(
                        alpha: 0.25 * (1.0 - _pulseController.value),
                      ),
                    ),
                  );
                },
              ),
              AnimatedScale(
                scale: widget.isSelected ? 1.25 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: widget.isSelected ? Colors.white : const Color(0xFF10B981),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA ILUMINAÇÃO DE FUNDO RADIAL (GLOW ORBS) ---
class GlowOrb extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const GlowOrb({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA HOVER E MICRO-ANIMAÇÕES ---
class HoverScaleContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const HoverScaleContainer({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<HoverScaleContainer> createState() => _HoverScaleContainerState();
}

class _HoverScaleContainerState extends State<HoverScaleContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA ANIMAÇÃO ESCALONADA (STAGGERED FADE-IN + SLIDE-UP) ---
class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInSlideUp({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Timer(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
