import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  UserModel? _user;
  bool _isLoading = false;

  UserProvider({UserRepository? userRepository}) 
      : _userRepository = userRepository ?? UserRepository();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _setLoading(true);
    _user = await _userRepository.getUser();
    _setLoading(false);
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    _setLoading(true);
    _user = await _userRepository.updateUser(data);
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}