import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/usecases/export_flashcards.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FlashcardsExportDialog extends StatefulWidget {
  const FlashcardsExportDialog({Key? key}) : super(key: key);

  @override
  State<FlashcardsExportDialog> createState() => _FlashcardsExportDialogState();
}

class _FlashcardsExportDialogState extends State<FlashcardsExportDialog> {
  ExportFlashcardsUseCase exportFlashcards = GetIt.I();

  Future? exportFlashcardsFuture;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
              future: exportFlashcardsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorMessage(snapshot.error!);
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return _buildExortForm(context);
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return _buildWaiting(context);
                  case ConnectionState.done:
                    return _buildImportFinished(context);
                }
              }),
        ),
      ),
    );
  }

  Widget _buildExortForm(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        MyAppLocalizations.of(context).exportFlashcardsTitle + "?",
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      Text(MyAppLocalizations.of(context).exportFlashcardsExplanationMessage),
      SizedBox(
        height: 12,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              exportFlashcardsFuture = exportFlashcards.call();
            });
          },
          child: Text(MyAppLocalizations.of(context).exportFlashcardActionText.toUpperCase())),
      OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MyAppLocalizations.of(context).cancel.toUpperCase()))
    ]);
  }

  Widget _buildWaiting(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(MyAppLocalizations.of(context).exportFlashcardInProgressTitle,
            style: Theme.of(context).textTheme.headline6),
        SizedBox(
          height: 12,
        ),
        CircularProgressIndicator()
      ],
    );
  }

  Widget _buildErrorMessage(Object error) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        MyAppLocalizations.of(context).exportFlashcardsErrorTitle,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      Text(
        _getErrorMessageFromError(error),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      ElevatedButton(
          onPressed: () => Navigator.of(context).pop(), child: Text(MyAppLocalizations.of(context).close.toUpperCase()))
    ]);
  }

  String _getErrorMessageFromError(Object error) {
    switch (error.runtimeType) {
      case UserCanceledActionFailure:
        return MyAppLocalizations.of(context).exportFlashcardsUserCanceledErrorMessage;
      case InvalidBackupLocationFailure:
        return MyAppLocalizations.of(context).exportFlashcardsInvalidBackupLocationErrorMessage;
      default:
        return MyAppLocalizations.of(context).defaultErrorMessage;
    }
  }

  Widget _buildImportFinished(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          MyAppLocalizations.of(context).exportFlashcardsFinishedTitle,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          MyAppLocalizations.of(context).exportFlashcardsFinishedMessage,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: Text(MyAppLocalizations.of(context).close.toUpperCase()))
      ],
    );
  }
}
