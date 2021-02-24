import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:kt_dart/kt.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/notes/i_note_repository.dart';
import '../../domain/notes/note.dart';
import '../../domain/notes/note_failure.dart';
import '../../domain/notes/todo_item.dart';
import '../core/firestore_helpers.dart';
import 'note_dtos.dart';

@LazySingleton(as: INoteRepository)
class NoteRepository implements INoteRepository {
  NoteRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchAll() async* {
    final DocumentReference userDoc = await _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot snapshot) => right<NoteFailure, KtList<Note>>(
        snapshot.docs
            .map((QueryDocumentSnapshot doc) => NoteDto.fromFirestore(doc).toDomain())
            .toImmutableList(),
      ),
    )
        .onErrorReturnWith((dynamic e) {
      if (e is FirebaseException && e.message.contains('PERMISSION_DENIED')) {
        return left(const NoteFailure.insufficientPermission());
      } else {
        return left(const NoteFailure.unexpected());
      }
    });
  }

  @override
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted() async* {
    final DocumentReference userDoc = await _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot snapshot) =>
          snapshot.docs.map((QueryDocumentSnapshot doc) => NoteDto.fromFirestore(doc).toDomain()),
    )
        .map(
          (Iterable<Note> notes) => right<NoteFailure, KtList<Note>>(
        notes
            .where((Note note) =>
            note.todos.getOrCrash().any((TodoItem todoItem) => !todoItem.done))
            .toImmutableList(),
      ),
    )
        .onErrorReturnWith((dynamic e) {
      if (e is FirebaseException && e.message.contains('PERMISSION_DENIED')) {
        return left(const NoteFailure.insufficientPermission());
      } else {
        // log.error(e.toString());
        return left(const NoteFailure.unexpected());
      }
    });
  }

  @override
  Future<Either<NoteFailure, Unit>> create(Note note) async {
    try {
      final DocumentReference userDoc = await _firestore.userDocument();
      final NoteDto noteDto = NoteDto.fromDomain(note);

      await userDoc.noteCollection.doc(noteDto.id).set(noteDto.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        return left(const NoteFailure.insufficientPermission());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> update(Note note) async {
    try {
      final DocumentReference userDoc = await _firestore.userDocument();
      final NoteDto noteDto = NoteDto.fromDomain(note);

      await userDoc.noteCollection.doc(noteDto.id).update(noteDto.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        return left(const NoteFailure.insufficientPermission());
      } else if (e.message.contains('NOT_FOUND')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> delete(Note note) async {
    try {
      final DocumentReference userDoc = await _firestore.userDocument();
      final String noteId = note.id.getOrCrash();

      await userDoc.noteCollection.doc(noteId).delete();

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        return left(const NoteFailure.insufficientPermission());
      } else if (e.message.contains('NOT_FOUND')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        return left(const NoteFailure.unexpected());
      }
    }
  }
}