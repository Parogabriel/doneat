import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Importações de Modelos e Serviços
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/app_state_provider.dart';

// Importações de Telas
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/shared/impact_screen.dart';
import 'screens/donor/donation_flow_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/financial_screen.dart';

// Importações de Widgets
import 'widgets/bottom_nav.dart';
import 'widgets/responsive_layout.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => MockAuthService(),
        ),
        Provider<DatabaseService>(
          create: (_) => MockDatabaseService(),
        ),
        ChangeNotifierProvider<AppStateProvider>(
          create: (context) => AppStateProvider(
            authService: context.read<AuthService>(),
            dbService: context.read<DatabaseService>(),
          ),
        ),
      ],
      child: const DoneatApp(),
    ),
  );
}

class DoneatApp extends StatelessWidget {
  const DoneatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doneat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        if (mediaQuery.size.width >= 768) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: child,
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }
      },
      home: const RootAuthGate(),
    );
  }
}

class RootAuthGate extends StatelessWidget {
  const RootAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    // 1. Tratamento Defensivo de Erro de GPS
    if (state.gpsError) {
      return const GpsErrorScreen();
    }

    // 2. Tela de Carregamento Premium durante a busca inicial do GPS ou autenticação
    if (state.isLoading && state.userLocation == null) {
      return const PremiumLoadingScreen();
    }

    // 3. Gatekeeper de Autenticação
    if (state.currentProfile == null) {
      return const LoginScreen();
    }

    // 4. Gatekeeper de Onboarding (Escolha de papel)
    if (state.currentProfile?.role == null) {
      return const OnboardingScreen();
    }

    // 5. Fluxo Principal Autenticado com Navegação
    return const MainNavigationWrapper();
  }
}

class PremiumLoadingScreen extends StatefulWidget {
  const PremiumLoadingScreen({super.key});

  @override
  State<PremiumLoadingScreen> createState() => _PremiumLoadingScreenState();
}

class _PremiumLoadingScreenState extends State<PremiumLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Detalhe giratório de borda
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 4,
                      ),
                    ),
                  ),
                ),
                // Caixa central com pulso da letra D
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'DONEAT PREMIUM',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFFCBD5E1),
                letterSpacing: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    Widget buildBody() {
      switch (state.currentPage) {
        case 'HOME':
          return const HomeScreen();
        case 'DASHBOARD':
          return const ImpactScreen();
        case 'DONATE':
          return const DonationFlowScreen();
        case 'TRACKING':
          return const TrackingScreen();
        case 'PROFILE':
          return const ProfileScreen();
        case 'FINANCIAL_DONATE':
          return const FinancialScreen();
        default:
          return const HomeScreen();
      }
    }

    return ResponsiveLayout(
      mobileBody: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: const NotificationsEndDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(state.currentPage),
                  child: buildBody(),
                ),
              ),
            ),
            if (state.currentPage != 'DONATE')
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNav(),
              ),
          ],
        ),
      ),
      webBody: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        endDrawer: const NotificationsEndDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(state.currentPage),
                  child: buildBody(),
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: WebHeaderNavbar(),
            ),
          ],
        ),
      ),
    );
  }
}

class WebNavLink extends StatefulWidget {
  final String label;
  final String pageKey;
  final bool isActive;
  final VoidCallback onTap;

  const WebNavLink({
    super.key,
    required this.label,
    required this.pageKey,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<WebNavLink> createState() => _WebNavLinkState();
}

class _WebNavLinkState extends State<WebNavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _isHovered ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: widget.isActive
                      ? const Color(0xFF10B981)
                      : (_isHovered ? Colors.white : Colors.white70),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: widget.isActive ? 24 : (_isHovered ? 12 : 0),
              color: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}

class WebHeaderNavbar extends StatelessWidget {
  const WebHeaderNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final current = state.currentPage;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.75),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => state.setCurrentPage('HOME'),
                child: const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: Color(0xFF10B981), size: 28),
                    SizedBox(width: 8),
                    Text(
                      'DONEAT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  WebNavLink(
                    label: 'Início',
                    pageKey: 'HOME',
                    isActive: current == 'HOME',
                    onTap: () => state.setCurrentPage('HOME'),
                  ),
                  const SizedBox(width: 32),
                  WebNavLink(
                    label: 'Doações',
                    pageKey: 'DONATE',
                    isActive: current == 'DONATE',
                    onTap: () => state.setCurrentPage('DONATE'),
                  ),
                  const SizedBox(width: 32),
                  WebNavLink(
                    label: 'Impacto',
                    pageKey: 'DASHBOARD',
                    isActive: current == 'DASHBOARD',
                    onTap: () => state.setCurrentPage('DASHBOARD'),
                  ),
                  const SizedBox(width: 32),
                  WebNavLink(
                    label: 'Perfil',
                    pageKey: 'PROFILE',
                    isActive: current == 'PROFILE',
                    onTap: () => state.setCurrentPage('PROFILE'),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.notifications_rounded, color: Colors.white70),
                    hoverColor: Colors.white10,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'NÍVEL ${state.currentProfile?.level ?? 1}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${state.currentProfile?.xp ?? 0} XP',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (state.currentProfile?.businessName ?? 'D').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsEndDrawer extends StatelessWidget {
  const NotificationsEndDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AVISOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildNotificationItem(
                title: 'Alimento reservado!',
                desc: 'A ONG Amigos aceitou sua doação de Marmitas de Lasanha.',
                time: '15m atrás',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                title: 'Conquista alcançada!',
                desc: 'Você desbloqueou a badge "Herói Regional" por ajudar a comunidade.',
                time: '2h atrás',
                icon: Icons.emoji_events_outlined,
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String desc,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
                    ),
                    Text(
                      time.toUpperCase(),
                      style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GpsErrorScreen extends StatelessWidget {
  const GpsErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'FALHA NA LOCALIZAÇÃO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                state.gpsErrorMessage ?? 'Não foi possível obter a sua localização GPS atual.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => state.retryGpsInitialization(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'TENTAR NOVAMENTE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
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
}
