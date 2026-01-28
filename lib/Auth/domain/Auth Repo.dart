
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/user model.dart';

abstract class AuthRepository {
  Future<Either<String, UserModel>> signUp({
    required String email,
    required String password,
  });
  Future<Either<String, UserModel>> signIn({
    required String email,
    required String password,
  });
  Future<Either<String, void>> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

// For Either type, you can use dartz package or create a simple one:
class Either<L, R> {
  final L? left;
  final R? right;

  Either.left(this.left) : right = null;
  Either.right(this.right) : left = null;

  bool get isLeft => left != null;
  bool get isRight => right != null;
}
