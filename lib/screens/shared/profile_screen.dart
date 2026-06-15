import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/app_state_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Notificações locais
  bool _pushNotifications = true;
  bool _emailMarketing = false;
  bool _impactAlerts = true;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final profile = state.currentProfile;

    final name = profile?.displayName ?? 'Carlos Eduardo';
    final email = profile?.email ?? 'carlos.eduardo@email.com';
    final role = profile?.role ?? UserRole.donor;
    final level = profile?.level ?? 1;
    final xp = profile?.xp ?? 0;

    final settingGroups = [
      {
        'title': 'Minha Conta',
        'items': [
          {'id': 'personal', 'icon': Icons.person_rounded, 'label': 'Informações Pessoais', 'color': Colors.blue, 'value': name.split(' ')[0]},
          {'id': 'security', 'icon': Icons.shield_rounded, 'label': 'Segurança e Senha', 'color': Colors.green},
          {'id': 'address', 'icon': Icons.location_on_rounded, 'label': 'Meus Endereços', 'color': Colors.orange, 'value': 'Centro'},
        ]
      },
      {
        'title': 'Preferências',
        'items': [
          {'id': 'notifications', 'icon': Icons.notifications_rounded, 'label': 'Notificações', 'color': Colors.purple, 'value': _pushNotifications ? 'Ativo' : 'Inativo'},
          {'id': 'history', 'icon': Icons.receipt_long_rounded, 'label': 'Doações Recebidas', 'color': Colors.pink},
          {'id': 'general', 'icon': Icons.settings_rounded, 'label': 'Ajustes Gerais', 'color': Colors.blueGrey},
        ]
      },
      {
        'title': 'Suporte',
        'items': [
          {'id': 'help', 'icon': Icons.help_outline_rounded, 'label': 'Central de Ajuda', 'color': Colors.amber},
        ]
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: Column(
          children: [
            // Header Premium
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(64)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE2E8F0),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorações
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8F5E9).withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 32, left: 24, right: 24),
                    child: Column(
                      children: [
                        // Foto de Perfil com ícone de Smartphone
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=300&auto=format&fit=crop',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Nome e Email
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Emblema da Conta
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: role == UserRole.donor ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: role == UserRole.donor ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2),
                            ),
                          ),
                          child: Text(
                            role == UserRole.donor ? 'DOADOR PREMIUM' : 'INSTITUIÇÃO PARCEIRA',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: role == UserRole.donor ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Estatísticas de Nível / XP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'NÍVEL',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level.toString(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Container(
                              height: 32,
                              width: 1.5,
                              color: Colors.grey[100],
                              margin: const EdgeInsets.symmetric(horizontal: 36),
                            ),
                            Column(
                              children: [
                                Text(
                                  'TOTAL XP',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 1.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  xp.toString(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Grupos de Opções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: settingGroups.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 16.0),
                        child: Text(
                          (group['title'] as String).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (group['items'] as List).length,
                          itemBuilder: (context, idx) {
                            final item = (group['items'] as List)[idx];
                            final isLast = idx == (group['items'] as List).length - 1;

                            return Column(
                              children: [
                                ListTile(
                                  onTap: () => _showModal(context, item['id'] as String),
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: (item['color'] as Color).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                                  ),
                                  title: Text(
                                    (item['label'] as String).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (item['value'] != null)
                                        Text(
                                          (item['value'] as String).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.grey[300],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Icon(Icons.chevron_right_rounded, color: Colors.grey[200]),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    height: 1,
                                    color: const Color(0xFFF8FAFC),
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Botão Sair da Conta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () => state.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFFEBEE)),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'SAIR DA CONTA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Opacity(
              opacity: 0.2,
              child: Text(
                'DONEAT V1.0.0 PREMIUM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModal(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getModalTitle(id).toUpperCase(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildModalContent(id, setModalState),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      foregroundColor: Colors.grey[400],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('FECHAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getModalTitle(String id) {
    switch (id) {
      case 'personal':
        return 'Informações Pessoais';
      case 'security':
        return 'Segurança';
      case 'address':
        return 'Meus Endereços';
      case 'notifications':
        return 'Notificações';
      case 'history':
        return 'Doações Recebidas';
      case 'general':
        return 'Ajustes Gerais';
      case 'help':
        return 'Ajuda';
      default:
        return 'Detalhes';
    }
  }

  Widget _buildModalContent(String id, StateSetter setModalState) {
    if (id == 'notifications') {
      return Column(
        children: [
          _buildToggleItem(
            title: 'Notificações Push',
            desc: 'Alertas em tempo real no aplicativo',
            value: _pushNotifications,
            onChanged: (val) {
              setState(() => _pushNotifications = val);
              setModalState(() => _pushNotifications = val);
            },
          ),
          const SizedBox(height: 12),
          _buildToggleItem(
            title: 'E-mail Marketing',
            desc: 'Promoções e notícias exclusivas',
            value: _emailMarketing,
            onChanged: (val) {
              setState(() => _emailMarketing = val);
              setModalState(() => _emailMarketing = val);
            },
          ),
          const SizedBox(height: 12),
          _buildToggleItem(
            title: 'Alertas de Impacto',
            desc: 'Resumos semanais do seu progresso social',
            value: _impactAlerts,
            onChanged: (val) {
              setState(() => _impactAlerts = val);
              setModalState(() => _impactAlerts = val);
            },
          ),
        ],
      );
    } else if (id == 'personal') {
      final state = Provider.of<AppStateProvider>(context, listen: false);
      return Column(
        children: [
          const Icon(Icons.account_box_rounded, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            state.currentProfile?.displayName ?? 'Carlos Eduardo',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Doador ativo desde 2026',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Center(child: Text('EDITAR DADOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
          ),
        ],
      );
    } else if (id == 'security') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFC8E6C9)),
        ),
        child: Column(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 48),
            const SizedBox(height: 16),
            const Text(
              'AMBIENTE SEGURO',
              style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Seus dados estão protegidos por criptografia de ponta a ponta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text('CONFIGURAR 2FA', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 10)),
            ),
          ],
        ),
      );
    } else if (id == 'help' || id == 'general') {
      final items = [
        {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat de Suporte'},
        {'icon': Icons.help_outline_rounded, 'label': 'Perguntas Frequentes'},
        {'icon': Icons.report_problem_outlined, 'label': 'Reportar um Problema'},
        {'icon': Icons.language_rounded, 'label': 'Idioma e Região'},
        {'icon': Icons.dark_mode_outlined, 'label': 'Modo Escuro'},
      ];

      return Column(
        children: items.map((it) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(it['icon'] as IconData, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 16),
                    Text(
                      (it['label'] as String).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 11),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 16),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      // Doações / histórico vazio
      return Column(
        children: [
          const SizedBox(height: 16),
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'NENHUM HISTÓRICO ENCONTRADO',
            style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Sua primeira doação iniciará este registro.',
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
          ),
        ],
      );
    }
  }

  Widget _buildToggleItem({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF8FAFC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[400], fontSize: 9),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFFE8F5E9),
          ),
        ],
      ),
    );
  }
}
