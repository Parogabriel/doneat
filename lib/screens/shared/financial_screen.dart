import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  double _amount = 50.0;
  bool _success = false;

  void _donate() {
    setState(() {
      _success = true;
    });

    // Aguarda 2.5 segundos e retorna para a Home
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final state = Provider.of<AppStateProvider>(context, listen: false);
        state.setCurrentPage('HOME');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_success) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Coração Animado (Icone com efeito de fundo)
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Color(0xFF2E7D32), size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'MUITO OBRIGADO!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua doação ajudará a combater a fome e o desperdício de alimentos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => state.setCurrentPage('HOME'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const Text(
                    'DOAÇÃO FINANCEIRA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),
              const SizedBox(height: 32),

              // Card Principal
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(28),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icone de Aperto de Mãos com Coração
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFF97316), size: 28),
                          ),
                        ),

                        const Text(
                          'FAÇA A DIFERENÇA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sua contribuição permite que nossa rede chegue a mais famílias todos os dias.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Valor Grande
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'R\$ ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF81C784),
                              ),
                            ),
                            Text(
                              _amount.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2.0,
                                color: Color(0xFF10B981),
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Slider
                        Slider(
                          value: _amount,
                          min: 5.0,
                          max: 500.0,
                          divisions: 99, // Incrementos de 5 em 5
                          activeColor: const Color(0xFF10B981),
                          inactiveColor: const Color(0xFFF1F5F9),
                          onChanged: (val) {
                            setState(() {
                              _amount = val;
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'R\$ 5',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey),
                              ),
                              Text(
                                'R\$ 500',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botões de Valor Rápido
                        Row(
                          children: [20, 50, 100].map((val) {
                            final isSelected = _amount.toInt() == val;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _amount = val.toDouble()),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFFF8FAFC),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'R\$ $val',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Badge de Segurança
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'DOAÇÃO 100% SEGURA E TRANSPARENTE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botão Concluir Doação
              ElevatedButton(
                onPressed: _donate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'CONCLUIR DOAÇÃO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFF10B981)),
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
