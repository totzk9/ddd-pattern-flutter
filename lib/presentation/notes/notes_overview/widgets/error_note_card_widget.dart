import 'package:flutter/material.dart';

import '../../../../domain/core/failures.dart';
import '../../../../domain/notes/note.dart';

class ErrorNoteCard extends StatelessWidget {
  const ErrorNoteCard({
    Key key,
    @required this.note,
  }) : super(key: key);

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).errorColor,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Text(
              'Invalid note, please, contact support',
              style: Theme.of(context)
                  .primaryTextTheme
                  .bodyText2
                  .copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              'Details:',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            Text(
              note.failureOption
                  .fold(() => '', (ValueFailure f) => f.toString()),
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
