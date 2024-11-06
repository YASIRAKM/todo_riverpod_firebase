import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_flutter_toto_app/model/todo_model.dart';
import 'package:riverpod_flutter_toto_app/repo/fire_store_repository.dart';
import 'package:riverpod_flutter_toto_app/utils/error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

part "todo_provider.g.dart";

@riverpod
class TodoNotifier extends _$TodoNotifier {
  late final FirestoreRepository firestoreRepository =
      ref.read(firestoreRepositoryProvider);
  List<Todo> todos = [];

  @override
  List<Todo> build() {
    fetchAllTodos();
    return todos;
  }

  void addTodo(
    BuildContext context,
    Todo todo,
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String mail = pref.getString("mail") ?? "";

    final result = await firestoreRepository.addTodo(todo, mail);
    if (result.$1) {
      state = [...state, todo];
    } else {
      showErrorDialog(context, result.$2);
    }
  }

  void updateTodo(BuildContext context, Todo todo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String mail = pref.getString("mail") ?? "";
    final result = await firestoreRepository.updateTodo(todo, mail);
    if (result.$1) {
      state = [
        for (final item in state)
          if (item.id == todo.id) todo else item
      ];
    } else {
      showErrorDialog(context, result.$2);
    }
  }

  void deleteTodo(BuildContext context, Todo todo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String mail = pref.getString("mail") ?? "";
    final result = await firestoreRepository.deleteTodo(todo, mail);
    if (result.$1) {
      // Remove todo from state
      state = state.where((item) => item.id != todo.id).toList();
    } else {
      showErrorDialog(context, result.$2);
    }
  }

  void fetchAllTodos({String? titleFilter, String? orderByField}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String mail = pref.getString("mail") ?? "";
    await for (final todos in firestoreRepository.fetchAllTodo(
        orderByField: orderByField, titleFilter: titleFilter, mail: mail)) {
      state = todos;
    }
  }
}
final checkboxProvider = StateProvider<bool>((ref) => false);
final filterProvider = StateProvider<String>((ref) => "all");