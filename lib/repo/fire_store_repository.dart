import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_flutter_toto_app/model/todo_model.dart';

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

class FirestoreRepository {
  // final FirebaseFirestore _firestore;

  FirestoreRepository();

  final CollectionReference _notesCollection =
      FirebaseFirestore.instance.collection('todo');
  Future<(bool, String)> addTodo(Todo todo, String mail) async {
    try {
      await _notesCollection.doc("sss").collection(mail).add(todo.toJson());
      return (true, "success");
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> updateTodo(Todo todo, String mail) async {
    try {
      await _notesCollection
          .doc("sss")
          .collection(mail)
          .doc(todo.id)
          .update(todo.toJson());
      return (true, "success");
    } catch (e) {
      return (false, e.toString());
    }
  }

  Future<(bool, String)> deleteTodo(Todo todo, String mail) async {
    try {
      await _notesCollection.doc("sss").collection(mail).doc(todo.id).delete();
      return (true, "success");
    } catch (e) {
      return (false, e.toString());
    }
  }

  Stream<List<Todo>> fetchAllTodo(
      {String? titleFilter, String? orderByField, required String mail}) {
    Query query = _notesCollection.doc("sss").collection(mail);

    // Add where condition if titleFilter is provided
    if (titleFilter != null && titleFilter.isNotEmpty) {
      query = query.where('status', isEqualTo: int.parse(titleFilter));
    }

    // Add ordering if orderByField is provided
    if (orderByField != null) {
      query = query.orderBy(orderByField);
    }

    // Return the stream of notes
    return query.snapshots().map((snapshot) {
      final data = snapshot.docs.map((doc) => Todo.fromDocument(doc)).toList();
      return data;
    });
  }
}
