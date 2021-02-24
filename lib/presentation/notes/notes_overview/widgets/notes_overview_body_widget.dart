import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../application/notes/note_watcher/note_watcher_bloc.dart';
import '../../../../domain/notes/note.dart';
import 'critical_failure_display_widget.dart';
import 'error_note_card_widget.dart';
import 'note_card_widget.dart';

class NotesOverviewBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteWatcherBloc, NoteWatcherState>(
      builder: (BuildContext context, NoteWatcherState state) {
        return state.map(
          initial: (_) => Container(),
          loadInProgress: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          loadSuccess: (state) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                final Note note = state.notes[index];
                if (note.failureOption.isSome()) {
                  return ErrorNoteCard(note: note);
                } else {
                  return NoteCard(note: note);
                }
              },
              itemCount: state.notes.size,
            );
          },
          loadFailure: (state) {
            return CriticalFailureDisplay(
              failure: state.noteFailure,
            );
          },
        );
      },
    );
  }
}