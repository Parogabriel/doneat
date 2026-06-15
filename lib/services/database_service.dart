import 'dart:async';
import '../models/donation.dart';
import '../models/user.dart';

abstract class DatabaseService {
  Stream<List<Donation>> getActiveDonations();
  Future<void> addDonation(Donation donation, User creator);
  Future<void> updateDonationStatus(String id, DonationStatus newStatus);
}

class MockDatabaseService implements DatabaseService {
  final _controller = StreamController<List<Donation>>.broadcast();
  final List<Donation> _donations = [];

  MockDatabaseService() {
    _donations.addAll([
      Donation(
        id: 'don_1',
        donorId: 'mock_user_123',
        title: 'Marmitas de Lasanha Presunto e Queijo',
        description: 'Lasanha fresca do almoço de hoje. Embalagens individuais térmicas.',
        category: DonationCategory.meals,
        quantity: 5,
        unit: 'porções',
        expirationTime: DateTime.now().add(const Duration(hours: 4)),
        status: DonationStatus.available,
        location: const DonationLocation(
          lat: -23.5585,
          lng: -46.6603,
          address: 'Alameda Lorena, 1500 - Cerqueira César',
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=600&auto=format&fit=crop',
      ),
      Donation(
        id: 'don_2',
        donorId: 'donor_padoca',
        title: 'Pães de Fermentação Natural Variados',
        description: 'Ciabattas, baguetes e pão sourdough assados hoje de manhã.',
        category: DonationCategory.breads,
        quantity: 12,
        unit: 'unidades',
        expirationTime: DateTime.now().add(const Duration(hours: 8)),
        status: DonationStatus.available,
        location: const DonationLocation(
          lat: -23.5615,
          lng: -46.6553,
          address: 'Rua Augusta, 800 - Consolação',
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=600&auto=format&fit=crop',
      ),
      Donation(
        id: 'don_3',
        donorId: 'donor_horti',
        title: 'Cesta de Frutas Selecionadas',
        description: 'Bananas, maçãs e laranjas em excelente estado para consumo.',
        category: DonationCategory.fruits,
        quantity: 3,
        unit: 'kg',
        expirationTime: DateTime.now().add(const Duration(hours: 24)),
        status: DonationStatus.available,
        location: const DonationLocation(
          lat: -23.5535,
          lng: -46.6623,
          address: 'Avenida Paulista, 2000 - Bela Vista',
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        image: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=600&auto=format&fit=crop',
      ),
    ]);
    _emit();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_donations));
  }

  @override
  Stream<List<Donation>> getActiveDonations() {
    return _controller.stream.map(
      (list) => list.where((d) => d.status == DonationStatus.available).toList(),
    );
  }

  @override
  Future<void> addDonation(Donation donation, User creator) async {
    if (donation.quantity <= 0) {
      throw ArgumentError('A quantidade da doação deve ser maior que zero.');
    }
    if (creator.role != UserRole.donor) {
      throw const SecurityException('Operação negada: apenas doadores podem criar anúncios de alimentos.');
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _donations.add(donation);
    _emit();
  }

  @override
  Future<void> updateDonationStatus(String id, DonationStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _donations.indexWhere((d) => d.id == id);
    if (index != -1) {
      _donations[index] = _donations[index].copyWith(status: newStatus);
      _emit();
    }
  }
}

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => message;
}
