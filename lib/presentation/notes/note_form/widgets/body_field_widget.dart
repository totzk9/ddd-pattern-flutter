import 'package:ddd_pattern_flutter/domain/core/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../domain/notes/value_objects.dart';

class BodyField extends HookWidget {
  const BodyField({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = useTextEditingController();

    return BlocListener<NoteFormBloc, NoteFormState>(
      listenWhen: (NoteFormState p, NoteFormState c) => p.isEditing != c.isEditing,
      listener: (BuildContext context, NoteFormState state) {
        textEditingController.text = state.note.body.getOrCrash();
      },
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: TextFormField(
            controller: textEditingController,
            decoration: const InputDecoration(
              labelText: 'Note',
              counterText: '',
            ),
            maxLength: NoteBody.maxLength,
            maxLines: null,
            minLines: 5,
            onChanged: (String value) => context
                .read<NoteFormBloc>()
                .add(NoteFormEvent.bodyChanged(value)),
            validator: (_) => context
                .read<NoteFormBloc>()
                .state
                .note
                .body
                .value
                .fold(
                  (ValueFailure<String> f) => f.maybeMap(
                empty: (Empty<String> f) => 'Cannot be empty',
                exceedingLength: (ExceedingLength<String> f) => 'Exceeding length, max: ${f.max}',
                orElse: () => null,
              ),
                  (String r) => null,
            ),
          )),
    );
  }
}