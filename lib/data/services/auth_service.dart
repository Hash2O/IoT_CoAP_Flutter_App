import '../../domain/models/user.dart';
import '../mock/mock_users.dart';

class AuthService {

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User?> login(
    String username,
    String password,
  ) async {

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    try {

      final user = mockUsers.firstWhere(
        (u) =>
            u.username == username &&
            u.password == password,
      );

      _currentUser = user;

      return user;

    } catch (_) {

      return null;
    }
  }

  void logout() {
    _currentUser = null;
  }
}