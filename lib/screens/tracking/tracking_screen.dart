import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isSheetExpanded = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Área do Mapa (Imagem do mapa estilizado cobrindo a parte superior)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1200&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradiente escuro superior
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Marcador do Estabelecimento (Doador)
                Positioned(
                  top: size.height * 0.28,
                  left: size.width * 0.40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=100&auto=format&fit=crop',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                // Marcador do Veículo em Trânsito (Motorista)
                Positioned(
                  top: size.height * 0.20,
                  left: size.width * 0.58,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF97316).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Text(
                          'EM TRÂNSITO',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Overlay de Informação Superior (Status da Coleta)
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS DA COLETA',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'O motorista está a caminho',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '6 MIN',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: -0.5),
                      ),
                      Text(
                        'RESTANTES',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sliding Bottom Sheet (Painel de Coleta)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            left: 0,
            right: 0,
            bottom: 0,
            height: _isSheetExpanded ? size.height * 0.52 : 110,
            child: Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 32,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  GestureDetector(
                    onTap: () => setState(() => _isSheetExpanded = !_isSheetExpanded),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Info do Motorista
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Marcos Silva',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'ONG AMIGOS',
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFE65100)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• 98% entregas',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildDriverActionButton(Icons.chat_bubble_outline_rounded, Colors.grey[400]!),
                          const SizedBox(width: 8),
                          _buildDriverActionButton(Icons.phone_outlined, const Color(0xFF10B981), isPrimary: true),
                        ],
                      ),
                    ],
                  ),

                  // Elementos expandíveis (Endereços rota)
                  if (_isSheetExpanded) ...[
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            _buildRoutePoint(
                              title: 'Bella Bakery & Confeitaria',
                              subtitle: 'Pedido: 🍱 10x Refeições do dia',
                              tag: 'Doador',
                              tagColor: const Color(0xFF10B981),
                              icon: Icons.store_rounded,
                              isFirst: true,
                            ),
                            const SizedBox(height: 12),
                            _buildRoutePoint(
                              title: 'Banco de Alimentos Municipal',
                              subtitle: 'Rua das Flores, 123 - Centro',
                              tag: 'Destino',
                              tagColor: const Color(0xFFF97316),
                              icon: Icons.location_on_rounded,
                              isFirst: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Ação de concluir ou ver detalhes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text(
                            'DETALHES DA COLETA',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverActionButton(IconData icon, Color color, {bool isPrimary = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isPrimary ? color : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Icon(icon, color: isPrimary ? Colors.white : color, size: 20),
    );
  }

  Widget _buildRoutePoint({
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required bool isFirst,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tagColor, size: 16),
            ),
            if (isFirst)
              Container(
                width: 2,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  // Estilo pontilhado no futuro ou linha simples por enquanto
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag.toUpperCase(),
                style: TextStyle(
                  color: tagColor,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
