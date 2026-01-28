
import 'package:hotel_app/Auth/data/user%20model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/Auth Repo.dart';
import '../domain/AuthRemoteDataSource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, UserModel>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
      );
      return Either.right(user);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Either.right(user);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return Either.right(null);
    } catch (e) {
      return Either.left(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Stream<AuthState> get authStateChanges =>
      remoteDataSource.authStateChanges;
}
