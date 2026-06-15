import 'dart:async';
import '../models/user.dart';

abstract class AuthService {
  Stream<User?> get onAuthStateChanged;
  Future<User?> loginWithGoogle();
  Future<void> logout();
  User? get currentUser;
  Future<User> saveProfile(User profile);
}

class MockAuthService implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  MockAuthService() {
    _controller.add(null);
  }

  @override
  Stream<User?> get onAuthStateChanged => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User?> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _currentUser = const User(
      userId: 'mock_user_123',
      displayName: 'Carlos Eduardo',
      email: 'carlos.eduardo@email.com',
      role: null,
      xp: 2850,
      level: 2,
      badges: ['1', '2', '3', '4'],
      location: UserLocation(lat: -23.5585, lng: -46.6603),
    );
    
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<User> saveProfile(User profile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = profile;
    _controller.add(_currentUser);
    return _currentUser!;
  }
}
