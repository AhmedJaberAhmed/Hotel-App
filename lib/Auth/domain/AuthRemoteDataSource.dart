import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/user model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({required String email, required String password});
  Future<UserModel> signIn({required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Sign up failed (no user returned).');
      }

      // Try to create profile (might fail if RLS is wrong)
      await _ensureUserProfileExists(user.id);

      return UserModel(
        id: user.id,
        email: user.email ?? email,
      );
    } catch (e, st) {
      debugPrint('Sign up error: $e');
      debugPrintStack(stackTrace: st);
      throw Exception('Sign up error: $e');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Sign in failed (no user returned).');
      }

      // Fetch profile safely
      final profileData = await supabaseClient
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      // If profile missing, try to create it (common when RLS blocked signUp insert)
      if (profileData == null) {
        await _ensureUserProfileExists(user.id);

        // Re-fetch (optional)
        final createdProfile = await supabaseClient
            .from('user_profiles')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        return UserModel(
          id: user.id,
          email: user.email ?? email,
          fullName: createdProfile?['full_name'],
          phone: createdProfile?['phone'],
          avatarUrl: createdProfile?['avatar_url'],
        );
      }

      return UserModel(
        id: user.id,
        email: user.email ?? email,
        fullName: profileData['full_name'],
        phone: profileData['phone'],
        avatarUrl: profileData['avatar_url'],
      );
    } catch (e, st) {
      debugPrint('Sign in error: $e');
      debugPrintStack(stackTrace: st);
      throw Exception('Sign in error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e, st) {
      debugPrint('Sign out error: $e');
      debugPrintStack(stackTrace: st);
      throw Exception('Sign out error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final profileData = await supabaseClient
          .from('user_profiles')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (profileData == null) {
        // If profile missing, still return base user instead of null
        return UserModel(
          id: user.id,
          email: user.email ?? '',
        );
      }

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: profileData['full_name'],
        phone: profileData['phone'],
        avatarUrl: profileData['avatar_url'],
      );
    } catch (e, st) {
      debugPrint('getCurrentUser error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  @override
  Stream<AuthState> get authStateChanges => supabaseClient.auth.onAuthStateChange;

  Future<void> _ensureUserProfileExists(String userId) async {
    // Upsert is safer than insert (prevents duplicates)
    await supabaseClient.from('user_profiles').upsert({
      'user_id': userId,
      'full_name': null,
      'phone': null,
      'avatar_url': null,
    }, onConflict: 'user_id');
  }
}
