import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user.dart';
import '../models/donation.dart';
import 'auth_service.dart';
import 'database_service.dart';

class AppStateProvider with ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _dbService;

  User? _currentUser;
  List<Donation> _activeDonations = [];
  String _currentPage = 'HOME';
  
  bool _isLoading = false;
  String? _errorMessage;

  // Estados específicos para Geolocalização defensiva
  bool _gpsError = false;
  String? _gpsErrorMessage;
  UserLocation? _userLocation;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Donation>>? _donationsSubscription;

  AppStateProvider({
    required AuthService authService,
    required DatabaseService dbService,
  })  : _authService = authService,
        _dbService = dbService {
    _init();
  }

  void _init() {
    _isLoading = true;

    // Dispara a inicialização do GPS antes de processar a autenticação
    determinePosition().then((_) {
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        _startDonationsListener();
      }

      _authSubscription = _authService.onAuthStateChanged.listen((user) {
        _currentUser = user;
        _isLoading = false;
        if (user != null) {
          _startDonationsListener();
        } else {
          _stopDonationsListener();
          _activeDonations = [];
          _currentPage = 'HOME';
        }
        notifyListeners();
      });
    });
  }

  // Busca do posicionamento com timeout defensivo de 5s para evitar loading infinito
  Future<void> determinePosition() async {
    _isLoading = true;
    _gpsError = false;
    _gpsErrorMessage = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Os serviços de localização do GPS estão desativados nas configurações do dispositivo.");
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Permissão de localização do GPS negada pelo usuário.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("As permissões de localização foram negadas permanentemente. Por favor, ative nas configurações do dispositivo.");
      }

      // Timeout estrito de 5 segundos
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      _userLocation = UserLocation(lat: position.latitude, lng: position.longitude);
      _gpsError = false;
      
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(location: _userLocation);
      }
    } on TimeoutException {
      _gpsError = true;
      _gpsErrorMessage = "Tempo limite de resposta do GPS excedido (Timeout de 5s). Certifique-se de estar em um local aberto ou com sinal ativo.";
    } catch (e) {
      _gpsError = true;
      _gpsErrorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryGpsInitialization() async {
    await determinePosition();
  }

  void _startDonationsListener() {
    _donationsSubscription?.cancel();
    _donationsSubscription = _dbService.getActiveDonations().listen((donations) {
      _activeDonations = donations;
      notifyListeners();
    });
  }

  void _stopDonationsListener() {
    _donationsSubscription?.cancel();
    _donationsSubscription = null;
  }

  // Getters
  User? get currentProfile => _currentUser;
  List<Donation> get activeDonations => _activeDonations;
  String get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get gpsError => _gpsError;
  String? get gpsErrorMessage => _gpsErrorMessage;
  UserLocation? get userLocation => _userLocation;

  // Setters/Actions
  void setCurrentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.loginWithGoogle();
    } catch (e) {
      _errorMessage = 'Falha ao autenticar com o Google. Tente novamente.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.logout();
  }

  Future<void> completeOnboarding({
    required String name,
    required String role,
    String? businessName,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRole = UserRole.fromJson(role);
      final updatedProfile = _currentUser!.copyWith(
        displayName: name,
        role: userRole,
        businessName: businessName,
        xp: 0,
        level: 1,
        badges: [],
      );
      await _authService.saveProfile(updatedProfile);
    } catch (e) {
      _errorMessage = 'Falha ao salvar o perfil. Tente novamente.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishDonation({
    required String title,
    required String category,
    required int quantity,
    required String unit,
    required DateTime expirationTime,
    required String description,
    String? imageBase64,
  }) async {
    if (_currentUser == null) return false;

    // Validações rigorosas de regras de negócios
    if (_currentUser!.role != UserRole.donor) {
      throw SecurityException("Apenas doadores (DONOR) podem publicar novas doações.");
    }
    if (quantity <= 0) {
      throw ArgumentError("A quantidade do item deve ser maior que zero.");
    }
    if (expirationTime.isBefore(DateTime.now())) {
      throw ArgumentError("A data de validade para retirada deve ser futura.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newDonation = Donation(
        id: 'don_${DateTime.now().millisecondsSinceEpoch}',
        donorId: _currentUser!.userId,
        title: title,
        description: description,
        category: DonationCategory.fromJson(category),
        quantity: quantity,
        unit: unit,
        expirationTime: expirationTime,
        status: DonationStatus.available,
        location: DonationLocation(
          lat: _userLocation?.lat ?? -23.5585,
          lng: _userLocation?.lng ?? -46.6603,
          address: _currentUser!.businessName ?? 'Endereço cadastrado',
        ),
        createdAt: DateTime.now(),
        image: imageBase64,
      );

      await _dbService.addDonation(newDonation, _currentUser!);

      // Gerencia progresso de gamificação local
      await _awardXP(250); 
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao publicar doação.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reserveDonation(String donationId) async {
    if (_currentUser == null) return;

    try {
      await _dbService.updateDonationStatus(donationId, DonationStatus.reserved);
      await _awardXP(150);
      _currentPage = 'TRACKING';
    } catch (e) {
      _errorMessage = 'Erro ao reservar doação.';
      notifyListeners();
    }
  }

  Future<void> _awardXP(int amount) async {
    if (_currentUser == null) return;

    final newXp = _currentUser!.xp + amount;
    var newLevel = _currentUser!.level;

    if (newXp >= newLevel * 1000) {
      newLevel += 1;
    }

    final newBadges = List<String>.from(_currentUser!.badges);
    if (newXp >= 250 && !newBadges.contains('1')) {
      newBadges.add('1');
    }
    if (newXp >= 1000 && !newBadges.contains('2')) {
      newBadges.add('2');
    }
    if (newXp >= 2000 && !newBadges.contains('3')) {
      newBadges.add('3');
    }

    final updatedProfile = _currentUser!.copyWith(
      xp: newXp,
      level: newLevel,
      badges: newBadges,
    );

    await _authService.saveProfile(updatedProfile);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _donationsSubscription?.cancel();
    super.dispose();
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => message;
}
