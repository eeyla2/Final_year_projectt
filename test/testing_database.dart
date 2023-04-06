import 'package:legsfree/services/crud/crud_exceptions.dart';
import 'package:legsfree/services/crud/main_services.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

void main() {
  group('Database Authentication', () {
    final database = MainService();
    test('Database should not return DatabaseIsAlreadyOpen so thi should fail',
        () {
      expect(database.open(),
          throwsA(const TypeMatcher<UnableToGetDocumentException>()));
    });
/*
    test('Cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 minutes ',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );

      final badPassword =
          provider.createUser(email: 'someone@bar.com', password: 'foobar');

      expect(
        badPassword,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );

      expect(provider.currentUser, user);
    });

    test('Logged in User should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to login and logout again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
    */
  });
}
