import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/user_model.dart';
import 'package:google_docs_clone/repository/local_storage_repository.dart';
import 'package:google_docs_clone/utils/constants.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../models/response_model.dart';

final authRepositoryProvider = Provider(((ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorageRepository: LocalStorageRepository())));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository localStorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ResponseModel> signInWithGoogle() async {
    ResponseModel response =
        ResponseModel(error: 'Some unexpected error occured', data: null);
    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final userAccount = UserModel(
            displayName: user.displayName ?? '',
            email: user.email,
            photoUrl: user.photoUrl ?? '',
            uid: '',
            token: '');

        Response res = await _client.post(Uri.parse('$baseUrl/api/signup'),
            body: jsonEncode(userAccount),
            headers: {'Content-Type': 'application/json'});

        switch (res.statusCode) {
          case 200:
            final newUser = userAccount.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            response = ResponseModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      return ResponseModel(error: e.toString(), data: null);
    }
    return response;
  }

  Future<ResponseModel> getUserData() async {
    ResponseModel response =
        ResponseModel(error: 'Some unexpected error occured', data: null);
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        Response res = await _client.get(Uri.parse('$baseUrl/'), headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonDecode(res.body)['user'],
            ).copyWith(token: token);
            response = ResponseModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      return ResponseModel(error: e.toString(), data: null);
    }
    return response;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
