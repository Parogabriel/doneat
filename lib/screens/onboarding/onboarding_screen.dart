import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;
  String? _selectedRole;
  late TextEditingController _nameController;
  late TextEditingController _businessController;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppStateProvider>(context, listen: false);
    _nameController = TextEditingController(text: state.currentProfile?.displayName ?? '');
    _businessController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorações de fundo
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFF3E0).withValues(alpha: 0.4),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 1
                    ? _buildStep1(state, theme)
                    : _buildStep2(state, theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(AppStateProvider state, ThemeData theme) {
    return Column(
      key: const ValueKey('step1'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icone do Escudo
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 24),
          child: Transform.rotate(
            angle: -0.1,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
            ),
          ),
        ),

        Text(
          'BEM-VINDO AO DONEAT',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Qual será o seu papel na nossa missão de salvar alimentos?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 40),

        // Opção Doador
        _buildRoleButton(
          role: 'DONOR',
          title: 'Quero Doar',
          subtitle: 'Restaurantes & Mercados',
          activeColor: const Color(0xFF10B981),
          icon: Icons.store_rounded,
        ),
        const SizedBox(height: 16),

        // Opção Receptor
        _buildRoleButton(
          role: 'RECEIVER',
          title: 'Quero Receber',
          subtitle: 'ONGs & Movimentos',
          activeColor: const Color(0xFFF97316),
          icon: Icons.business_rounded,
        ),

        const SizedBox(height: 48),

        // Botão Avançar
        ElevatedButton(
          onPressed: _selectedRole == null
              ? null
              : () => setState(() => _step = 2),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PRÓXIMO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(AppStateProvider state, ThemeData theme) {
    final isDonor = _selectedRole == 'DONOR';
    final canSubmit = _nameController.text.isNotEmpty &&
        (!isDonor || _businessController.text.isNotEmpty);

    return Column(
      key: const ValueKey('step2'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _step = 1),
            child: Text(
              '← VOLTAR',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'QUASE LÁ!',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete seu perfil para começar.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 32),

        // Input Nome Completo
        _buildLabel('Nome Completo'),
        _buildTextField(
          controller: _nameController,
          hintText: 'Seu nome',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),

        // Input Nome do Estabelecimento (se for Doador)
        if (isDonor) ...[
          _buildLabel('Nome do Estabelecimento'),
          _buildTextField(
            controller: _businessController,
            hintText: 'Ex: Padaria Bella',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 20),
        ],

        // Input E-mail (Disabled)
        _buildLabel('E-mail'),
        Opacity(
          opacity: 0.5,
          child: _buildTextField(
            controller: TextEditingController(text: state.currentProfile?.email ?? ''),
            enabled: false,
            icon: Icons.mail_outline_rounded,
          ),
        ),

        const SizedBox(height: 48),

        // Botão Finalizar
        ElevatedButton(
          onPressed: !canSubmit || state.isLoading
              ? null
              : () => state.completeOnboarding(
                    name: _nameController.text,
                    role: _selectedRole!,
                    businessName: isDonor ? _businessController.text : null,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: Text(
            state.isLoading ? 'FINALIZANDO...' : 'COMEÇAR AGORA',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleButton({
    required String role,
    required String title,
    required String subtitle,
    required Color activeColor,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.grey[200]!,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : activeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : Colors.grey[400],
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String hintText = '',
    required IconData icon,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[300]),
          prefixIcon: Icon(icon, color: Colors.grey[300], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}
