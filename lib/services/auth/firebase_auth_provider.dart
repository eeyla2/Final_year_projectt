import 'package:firebase_core/firebase_core.dart';
import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/services/auth/auth_user.dart';
import 'package:legsfree/services/auth/auth_provider.dart';
import 'package:legsfree/services/auth/auth_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

//concrete implementation of auth provider

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      //if the exception FirebaseAuthException appears seremine type of Authexception
      if (e.code == 'weak-password') {
        //if exception is weak-password print weak password in terminal
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        //if exception is email-already-in-use print email is already in use in terminal
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        //if exception is invalid email print invalid email in terminal
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      //if the exception FirebaseAuthException appears check for type of Authexception
      //general catch statement
      if (e.code == 'user-not-found') {
        //if exception is user is not found display user not found
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        //if exception is wrong password entered print wrong password in terminal
        throw WrongPasswordAuthException();
      } else {
        //if exception falls underFirebaseException but is not wrong password or user not found then display error
        throw GenericAuthException();
      }
    } catch (_) {
      //if exception does not fall under FireBaseException then display error
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      //initializes application for the currentplatform in use
      //initiallization process
      options: DefaultFirebaseOptions.currentPlatform, //this line not working
    );
  }
}
