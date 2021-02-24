import 'package:auto_route/auto_route_annotations.dart';
import '../notes/note_form/note_form_page.dart';
import '../notes/notes_overview/notes_overview_page.dart';
import '../sign_in/sign_in_page.dart';
import '../splash/splash_page.dart';

@MaterialAutoRouter(
  generateNavigationHelperExtension: true,
  routes: <AutoRoute<dynamic>>[
    MaterialRoute<dynamic>(page: SplashPage, initial: true),
    MaterialRoute<dynamic>(page: SignInPage),
    MaterialRoute<dynamic>(page: NotesOverviewPage),
    MaterialRoute<dynamic>(page: NoteFormPage, fullscreenDialog: true),
  ],
)
class $Router {}