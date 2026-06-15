import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../models/user.dart';
import '../services/app_state_provider.dart';

class DonationCard extends StatefulWidget {
  final Donation donation;

  const DonationCard({super.key, required this.donation});

  static const Map<DonationCategory, String> categoryImages = {
    DonationCategory.meals: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop',
    DonationCategory.breads: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=300&auto=format&fit=crop',
    DonationCategory.fruits: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=300&auto=format&fit=crop',
    DonationCategory.vegetables: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=300&auto=format&fit=crop',
    DonationCategory.others: 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?q=80&w=300&auto=format&fit=crop',
  };

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context, listen: false);
    final role = state.currentProfile?.role;
    final timeStr = '${widget.donation.expirationTime.hour.toString().padLeft(2, '0')}:${widget.donation.expirationTime.minute.toString().padLeft(2, '0')}';
    final addressName = widget.donation.location.address.split(',')[0];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _isHovered 
                ? Colors.white.withValues(alpha: 0.08) 
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF10B981).withValues(alpha: 0.3) 
                  : Colors.white.withValues(alpha: 0.08), 
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.15),
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      DonationCard.categoryImages[widget.donation.category] ?? 
                          DonationCard.categoryImages[DonationCategory.others]!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.restaurant, size: 28, color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 88,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.donation.title.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                widget.donation.status.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10B981),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                addressName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.inventory_2_outlined,
                                        size: 12, color: Colors.white30),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.donation.quantity} ${widget.donation.unit}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 12, color: Colors.white30),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (role == UserRole.receiver &&
                                widget.donation.status == DonationStatus.available)
                              ElevatedButton(
                                onPressed: () =>
                                    state.reserveDonation(widget.donation.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'RESERVAR',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, size: 10),
                                  ],
                                ),
                              )
                            else
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_right_rounded,
                                    color: Colors.white30, size: 14),
                              ),
                          ],
                        ),
                      ],
                    ),
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
