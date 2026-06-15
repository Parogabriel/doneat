import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state_provider.dart';

class DonationFlowScreen extends StatefulWidget {
  const DonationFlowScreen({super.key});

  @override
  State<DonationFlowScreen> createState() => _DonationFlowScreenState();
}

class _DonationFlowScreenState extends State<DonationFlowScreen> {
  int _step = 1;
  String _selectedCategory = 'Refeições';
  int _quantity = 1;
  String _selectedUnit = 'unidades';
  String? _mockImage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _expirationTime;
  String _selectedQuickOption = '4h';

  @override
  void initState() {
    super.initState();
    _expirationTime = DateTime.now().add(const Duration(hours: 4));
  }

  final List<Map<String, dynamic>> _categories = [
    {'id': 'Refeições', 'icon': '🍱', 'desc': 'Pratos prontos'},
    {'id': 'Salgados', 'icon': '🥐', 'desc': 'Assados e fritos'},
    {'id': 'Doces', 'icon': '🍰', 'desc': 'Sobremesas'},
    {'id': 'Bebidas', 'icon': '🥤', 'desc': 'Sucos e refris'},
    {'id': 'In Natura', 'icon': '🍎', 'desc': 'Frutas e vegetais'},
    {'id': 'Outros', 'icon': '📦', 'desc': 'Itens diversos'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o título da doação.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (_expirationTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, defina o horário de validade.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final state = Provider.of<AppStateProvider>(context, listen: false);
    try {
      final success = await state.publishDonation(
        title: _titleController.text,
        category: _selectedCategory,
        quantity: _quantity,
        unit: _selectedUnit,
        expirationTime: _expirationTime!,
        description: _descController.text,
        imageBase64: _mockImage,
      );

      if (success && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SuccessDialog(),
        );

        if (mounted) {
          _titleController.clear();
          _descController.clear();
          setState(() {
            _step = 1;
            _selectedCategory = 'Refeições';
            _quantity = 1;
            _selectedUnit = 'unidades';
            _mockImage = null;
            _selectedQuickOption = '4h';
            _expirationTime = DateTime.now().add(const Duration(hours: 4));
          });
          state.setCurrentPage('HOME');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar doação: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);

    final List<Map<String, String>> stepInfos = [
      {'title': 'O Que Vai Doar?', 'subtitle': 'Selecione a categoria do alimento'},
      {'title': 'Detalhes Técnicos', 'subtitle': 'Quantidade e foto do produto'},
      {'title': 'Informações Finais', 'subtitle': 'Validade e descrição'},
    ];

    final currentInfo = stepInfos[_step - 1];

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
                    onPressed: () {
                      if (_step > 1) {
                        setState(() => _step -= 1);
                      } else {
                        state.setCurrentPage('HOME');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const Text(
                    'NOVA DOAÇÃO',
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
              const SizedBox(height: 24),

              // Barra de Etapas (Step progress)
              Row(
                children: [1, 2, 3].map((s) {
                  final isActive = _step >= s;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF10B981) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Título da etapa
              Text(
                currentInfo['title']!.toUpperCase(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentInfo['subtitle']!.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 32),

              // Conteúdo da Etapa
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildStepContent(isLoader: state.isLoading),
                  ),
                ),
              ),

              // Botões de Ação Inferiores
              _buildBottomActionButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent({required bool isLoader}) {
    if (_step == 1) {
      return _buildStep1();
    } else if (_step == 2) {
      return _buildStep2();
    } else {
      return _buildStep3();
    }
  }

  Widget _buildStep1() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, idx) {
        final cat = _categories[idx];
        final isSelected = _selectedCategory == cat['id'];

        return CategoryCard(
          cat: cat,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedCategory = cat['id'];
              _step = 2;
            });
          },
        );
      },
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upload de Imagem Simulado
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _mockImage != null ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mockImage = _mockImage == null
                      ? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop'
                      : null;
                });
              },
              child: _mockImage != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(_mockImage!, fit: BoxFit.cover),
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'REMOVER FOTO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.cloud_upload_outlined, color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'ADICIONAR FOTO',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Aumenta em 3x as chances de coleta',
                            style: TextStyle(fontSize: 8, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Seletor de Quantidade
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
          ),
          child: Column(
            children: [
              const Text(
                'QUANTIDADE DESTE ITEM',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity -= 1);
                    },
                    icon: const Icon(Icons.remove_rounded, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: () => setState(() => _quantity += 1),
                    icon: const Icon(Icons.add_rounded, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Abas de Unidade (Pills)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: ['unidades', 'kg', 'porções'].map((u) {
                    final isSelected = _selectedUnit == u;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedUnit = u),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.grey[200]!,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            u.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: isSelected ? const Color(0xFF0F172A) : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Form de Título e Descrição
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O QUE VOCÊ ESTÁ DOANDO?',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Ex: Pães de queijo do dia',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'DETALHES EXTRAS (OPCIONAL)',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Embalagem, conservação, etc...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Validade
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_rounded, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'RETIRAR ATÉ QUE HORAS?',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickTimeChip('2h', '2 Horas', () {
                    setState(() {
                      _selectedQuickOption = '2h';
                      _expirationTime = DateTime.now().add(const Duration(hours: 2));
                    });
                  }),
                  _buildQuickTimeChip('4h', '4 Horas', () {
                    setState(() {
                      _selectedQuickOption = '4h';
                      _expirationTime = DateTime.now().add(const Duration(hours: 4));
                    });
                  }),
                  _buildQuickTimeChip('8h', '8 Horas', () {
                    setState(() {
                      _selectedQuickOption = '8h';
                      _expirationTime = DateTime.now().add(const Duration(hours: 8));
                    });
                  }),
                  _buildQuickTimeChip('Amanhã', 'Amanhã', () {
                    setState(() {
                      _selectedQuickOption = 'Amanhã';
                      _expirationTime = DateTime.now().add(const Duration(hours: 24));
                    });
                  }),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 7)),
                  );
                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 4))),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _selectedQuickOption = 'custom';
                        _expirationTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedQuickOption == 'custom'
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF8FAFC),
                  foregroundColor: _selectedQuickOption == 'custom'
                      ? Colors.white
                      : const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedQuickOption == 'custom' && _expirationTime != null
                          ? 'Personalizado: ${_formatExpirationTime(_expirationTime!)}'
                          : 'Outra Data e Horário...',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _selectedQuickOption == 'custom' ? Colors.white70 : Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons(AppStateProvider state) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_step > 1) ...[
            IconButton(
              onPressed: () => setState(() => _step -= 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 24),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFF1F5F9)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      if (_step < 3) {
                        setState(() => _step += 1);
                      } else {
                        _submit();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _step < 3 ? 'AVANÇAR' : 'PUBLICAR DOAÇÃO',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _step < 3 ? Icons.chevron_right_rounded : Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTimeChip(String option, String label, VoidCallback onTap) {
    final isSelected = _selectedQuickOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0F172A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  String _formatExpirationTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final difference = target.difference(today).inDays;

    final String timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (difference == 0) {
      return 'Hoje às $timeStr';
    } else if (difference == 1) {
      return 'Amanhã às $timeStr';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às $timeStr';
    }
  }
}

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SUCESSO!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sua doação foi publicada com sucesso e já está disponível para retirada.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'IR PARA A HOME',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
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

class CategoryCard extends StatefulWidget {
  final Map<String, dynamic> cat;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.cat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    return AnimatedScale(
      scale: _isHovered ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) {
            setState(() {
              _isHovered = hovered;
            });
          },
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF4CAF50)
                    : (isSelected ? const Color(0xFF10B981) : Colors.transparent),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                      : (isSelected
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : Colors.grey[200]!.withValues(alpha: 0.4)),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cat['icon'] ?? '',
                  style: const TextStyle(fontSize: 28),
                ),
                const Spacer(),
                Text(
                  (widget.cat['id'] ?? '').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  (widget.cat['desc'] ?? '').toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
