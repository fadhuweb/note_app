abstract class IAuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  String? getCurrentUserId();
}
