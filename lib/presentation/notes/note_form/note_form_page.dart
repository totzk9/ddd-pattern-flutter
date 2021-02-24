import 'package:auto_route/auto_route.dart';
import 'package:dartz/dartz.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './misc/todo_item_presentation_classes.dart';
import './widgets/add_todo_tile_widget.dart';
import './widgets/body_field_widget.dart';
import './widgets/color_field_widget.dart';
import './widgets/todo_list_widget.dart';
import '../../../application/notes/note_form/note_form_bloc.dart';
import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_failure.dart';
import '../../../injection.dart';
import '../../routes/router.gr.dart';

class NoteFormPage extends StatelessWidget {
  const NoteFormPage({
    Key key,
    @required this.editedNote,
  }) : super(key: key);

  final Note editedNote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteFormBloc>(
      create: (BuildContext context) => getIt<NoteFormBloc>()
        ..add(NoteFormEvent.initialized(optionOf(editedNote))),
      child: BlocConsumer<NoteFormBloc, NoteFormState>(
        listenWhen: (NoteFormState p, NoteFormState c) =>
        p.saveFailureOrSuccessOption != c.saveFailureOrSuccessOption,
        listener: (BuildContext context, NoteFormState state) {
          state.saveFailureOrSuccessOption.fold(
                () {},
                (Either<NoteFailure, Unit> either) {
              either.fold(
                    (NoteFailure failure) {
                  FlushbarHelper.createError(
                    message: failure.map(
                      insufficientPermission: (_) =>
                      'Insufficient permissions ❌',
                      unableToUpdate: (_) =>
                      "Couldn't update the note. Was it deleted from another device?",
                      unexpected: (_) =>
                      'Unexpected error occurred, please contact support.',
                    ),
                  ).show(context);
                },
                    (_) {
                  ExtendedNavigator.of(context).popUntil(
                        (Route<dynamic> route) => route.settings.name == Routes.notesOverviewPage,
                  );
                },
              );
            },
          );
        },
        buildWhen: (NoteFormState p, NoteFormState c) => p.isSaving != c.isSaving,
        builder: (BuildContext context, NoteFormState state) {
          return Stack(
            children: <Widget>[
              const NoteFormPageScaffold(),
              SavingInProgressOverlay(isSaving: state.isSaving)
            ],
          );
        },
      ),
    );
  }
}

class SavingInProgressOverlay extends StatelessWidget {
  const SavingInProgressOverlay({
    Key key,
    @required this.isSaving,
  }) : super(key: key);

  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isSaving,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSaving ? Colors.black.withOpacity(0.8) : Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Visibility(
          visible: isSaving,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Saving',
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteFormPageScaffold extends StatelessWidget {
  const NoteFormPageScaffold({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NoteFormBloc, NoteFormState>(
          buildWhen: (NoteFormState p, NoteFormState c) => p.isEditing != c.isEditing,
          builder: (BuildContext context, NoteFormState state) {
            return Text(state.isEditing ? 'Edit a note' : 'Create a note');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              context.read<NoteFormBloc>().add(const NoteFormEvent.saved());
            },
          )
        ],
      ),
      body: BlocBuilder<NoteFormBloc, NoteFormState>(
        buildWhen: (NoteFormState p, NoteFormState c) => p.showErrorMessages != c.showErrorMessages,
        builder: (BuildContext context, NoteFormState state) {
          return ChangeNotifierProvider<FormTodos>(
            create: (_) => FormTodos(),
            child: Form(
              autovalidateMode: state.showErrorMessages ? AutovalidateMode.always : AutovalidateMode.disabled,
              child: SingleChildScrollView(
                child: Column(
                  children: const <Widget>[
                    BodyField(),
                    ColorField(),
                    TodoList(),
                    AddTodoTile(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}