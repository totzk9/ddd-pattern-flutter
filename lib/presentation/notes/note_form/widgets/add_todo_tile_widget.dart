import 'package:ddd_pattern_flutter/domain/core/failures.dart';
import 'package:ddd_pattern_flutter/domain/notes/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kt_dart/kt.dart';

import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../misc/build_context_x.dart';
import '../misc/todo_item_presentation_classes.dart';

class AddTodoTile extends StatelessWidget {
  const AddTodoTile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteFormBloc, NoteFormState>(
      listenWhen: (NoteFormState p, NoteFormState c) => p.isEditing != c.isEditing,
      listener: (BuildContext context, NoteFormState state) {
        context.formTodos = state.note.todos.value.fold(
              (ValueFailure<KtList<TodoItem>> f) => listOf<TodoItemPrimitive>(),
              (KtList<TodoItem> todoItemList) =>
              todoItemList.map((_) => TodoItemPrimitive.fromDomain(_)),
        );
      },
      buildWhen: (NoteFormState p, NoteFormState c) => p.note.todos.isFull != c.note.todos.isFull,
      builder: (BuildContext context, NoteFormState state) {
        return ListTile(
          enabled: !state.note.todos.isFull,
          title: const Text('Add a todo'),
          leading: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.add),
          ),
          onTap: () {
            context.formTodos =
                context.formTodos.plusElement(TodoItemPrimitive.empty());
            context.read<NoteFormBloc>().add(
              NoteFormEvent.todosChanged(context.formTodos),
            );
          },
        );
      },
    );
  }
}