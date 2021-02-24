import 'package:ddd_pattern_flutter/domain/core/failures.dart';
import 'package:ddd_pattern_flutter/domain/notes/todo_item.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:kt_dart/collection.dart';
import 'package:provider/provider.dart';

import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../domain/notes/value_objects.dart';
import '../misc/build_context_x.dart';
import '../misc/todo_item_presentation_classes.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (NoteFormState p, NoteFormState c) => p.note.todos.isFull != c.note.todos.isFull,
      listener: (BuildContext context, NoteFormState state) {
        if (state.note.todos.isFull) {
          FlushbarHelper.createAction(
            message: 'Want longer lists? Activate premium 🤩',
            button: FlatButton(
              onPressed: () {},
              child: const Text(
                'BUY NOW',
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            duration: const Duration(seconds: 5),
          ).show(context);
        }
      },
      child: Consumer<FormTodos>(
        builder: (BuildContext context, FormTodos formTodos, Widget child) {
          return ImplicitlyAnimatedReorderableList<TodoItemPrimitive>(
            shrinkWrap: true,
            removeDuration: const Duration(),
            items: formTodos.value.asList(),
            areItemsTheSame: (TodoItemPrimitive oldItem, TodoItemPrimitive newItem) => oldItem.id == newItem.id,
            onReorderFinished: (TodoItemPrimitive item, int from, int to, List<TodoItemPrimitive> newItems) {
              context.formTodos = newItems.toImmutableList();
              context
                  .read<NoteFormBloc>()
                  .add(NoteFormEvent.todosChanged(context.formTodos));
            },
            itemBuilder: (BuildContext context, Animation<double> itemAnimation, TodoItemPrimitive item, int index) {
              return Reorderable(
                key: ValueKey<dynamic>(item.id),
                builder: (BuildContext context, Animation<double> dragAnimation, bool inDrag) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 0.95)
                        .animate(dragAnimation),
                    child: TodoTile(
                      index: index,
                      elevation: dragAnimation.value * 4,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class TodoTile extends HookWidget {
  const TodoTile({
    @required this.index,
    double elevation,
    Key key,
  })  : elevation = elevation ?? 0,
        super(key: key);

  final int index;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final TodoItemPrimitive todo =
    context.formTodos.getOrElse(index, (_) => TodoItemPrimitive.empty());
    final TextEditingController textEditingController = useTextEditingController(text: todo.name);

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            context.formTodos = context.formTodos.minusElement(todo);
            context
                .read<NoteFormBloc>()
                .add(NoteFormEvent.todosChanged(context.formTodos));
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          elevation: elevation,
          animationDuration: const Duration(milliseconds: 50),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Checkbox(
                value: todo.done,
                onChanged: (bool value) {
                  context.formTodos = context.formTodos.map(
                        (TodoItemPrimitive listTodo) => listTodo == todo
                        ? todo.copyWith(done: value)
                        : listTodo,
                  );
                  context
                      .read<NoteFormBloc>()
                      .add(NoteFormEvent.todosChanged(context.formTodos));
                },
              ),
              trailing: const Handle(
                child: Icon(Icons.list),
              ),
              title: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Todo',
                  counterText: '',
                  border: InputBorder.none,
                ),
                maxLength: TodoName.maxLength,
                onChanged: (String value) {
                  context.formTodos = context.formTodos.map(
                        (TodoItemPrimitive listTodo) => listTodo == todo
                        ? todo.copyWith(name: value)
                        : listTodo,
                  );
                  context
                      .read<NoteFormBloc>()
                      .add(NoteFormEvent.todosChanged(context.formTodos));
                },
                validator: (_) {
                  return context
                      .read<NoteFormBloc>()
                      .state
                      .note
                      .todos
                      .value
                      .fold(
                    // Failure stemming from the TodoList length should NOT be displayed by the individual TextFormFields
                        (ValueFailure<KtList<TodoItem>> f) => null,
                        (KtList<TodoItem> todoList) => todoList[index].name.value.fold(
                          (ValueFailure<String> f) => f.maybeMap(
                        empty: (_) => 'Cannot be empty',
                        exceedingLength: (_) => 'Too long',
                        multiline: (_) => 'Has to be in a single line',
                        orElse: () => null,
                      ),
                          (_) => null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}