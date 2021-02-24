import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../application/notes/note_form/note_form_bloc.dart';
import '../../../../domain/notes/value_objects.dart';

class ColorField extends StatelessWidget {
  const ColorField({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteFormBloc, NoteFormState>(
      buildWhen: (NoteFormState p, NoteFormState c) => p.note.color != c.note.color,
      builder: (BuildContext context, NoteFormState state) {
        return Container(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: NoteColor.predefinedColors.length,
            itemBuilder: (BuildContext context, int index) {
              final Color itemColor = NoteColor.predefinedColors[index];
              return GestureDetector(
                onTap: () {
                  context
                      .read<NoteFormBloc>()
                      .add(NoteFormEvent.colorChanged(itemColor));
                },
                child: Material(
                  color: itemColor,
                  elevation: 4,
                  shape: CircleBorder(
                    side: state.note.color.value.fold(
                          (_) => BorderSide.none,
                          (Color color) => color == itemColor
                          ? const BorderSide(width: 1.5)
                          : BorderSide.none,
                    ),
                  ),
                  child: Container(
                    width: 50,
                    height: 50,
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 12);
            },
          ),
        );
      },
    );
  }
}