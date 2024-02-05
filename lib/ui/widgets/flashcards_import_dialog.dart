import 'package:flashcards/domain/models/failure.dart';
import 'package:flashcards/domain/usecases/import_flashcards.usecase.dart';
import 'package:flashcards/my_app_localizations.dart';
import 'package:flashcards/services/file_backup_service/file_backup_service.dart';
import 'package:flashcards/services/shared_data_receiver/shared_data_receiver.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FlashcardsImportDialog extends StatefulWidget {
  final SharedDataReceiver? dataReceiver;

  const FlashcardsImportDialog({Key? key, this.dataReceiver}) : super(key: key);

  @override
  State<FlashcardsImportDialog> createState() => _FlashcardsImportDialogState();
}

class _FlashcardsImportDialogState extends State<FlashcardsImportDialog> {
  Stream<ImportFlashcardsProgressTracker>? importStream;
  bool resetFlashcardsStrength = false;

  late ImportFlashcardsUseCase importFlashcards;

  @override
  void initState() {
    if (widget.dataReceiver == null) {
      importFlashcards = GetIt.I();
    } else {
      importFlashcards = ImportFlashcardsUseCase(
          categoryRepository: GetIt.I(),
          flashcardRepository: GetIt.I(),
          flashcardBackupService: SharedDataReceiverToBackupAdapter(dataReceiver: widget.dataReceiver!));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<ImportFlashcardsProgressTracker>(
              stream: importStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorMessage(snapshot.error!);
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return _buildImportForm(context);
                  case ConnectionState.waiting:
                    return _buildWaiting();
                  case ConnectionState.active:
                    return _buildImportInProgress(context, snapshot.requireData);
                  case ConnectionState.done:
                    return _buildImportFinished(context, snapshot.requireData);
                }
              }),
        ),
      ),
    );
  }

  Widget _buildImportForm(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        MyAppLocalizations.of(context).importFlashcardsTitle,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      SwitchListTile(
          title: Text(MyAppLocalizations.of(context).importFlashcardsResetProgressQuestion),
          value: resetFlashcardsStrength,
          subtitle: Text(MyAppLocalizations.of(context).importFlashcardsResetProgressAdvice),
          onChanged: (value) {
            setState(() {
              resetFlashcardsStrength = value;
            });
          }),
      SizedBox(
        height: 12,
      ),
      ElevatedButton(
          onPressed: () {
            setState(() {
              importStream = importFlashcards(resetFlashcadsStrength: resetFlashcardsStrength);
            });
          },
          child: Text(widget.dataReceiver == null
              ? MyAppLocalizations.of(context).pickFileAndImportFlashcardsActionText.toUpperCase()
              : MyAppLocalizations.of(context).importFlashcardsActionText.toUpperCase())),
      OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MyAppLocalizations.of(context).cancel.toUpperCase()))
    ]);
  }

  Widget _buildErrorMessage(Object error) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        MyAppLocalizations.of(context).importFlashcardsErrorTitle,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      Text(
        _getErrorMessageFromError(context, error),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      ElevatedButton(
          onPressed: () => Navigator.of(context).pop(), child: Text(MyAppLocalizations.of(context).close.toUpperCase()))
    ]);
  }

  String _getErrorMessageFromError(BuildContext context, Object error) {
    switch (error.runtimeType) {
      case UserCanceledActionFailure:
        return MyAppLocalizations.of(context).importFlashcardsUserCanceledErrorMessage;
      case InvalidBackupLocationFailure:
        return MyAppLocalizations.of(context).importFlashcardsInvalidBackupLocationErrorMessage;
      case UnsupportedFileFormatFailure:
        return MyAppLocalizations.of(context).unsopportedFileFormat;
      case CorruptedDataFailure:
        return MyAppLocalizations.of(context).importFlashcardsCorruptedDataErrorMessage;
      default:
        return MyAppLocalizations.of(context).defaultErrorMessage;
    }
  }

  Widget _buildWaiting() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [CircularProgressIndicator()],
    );
  }

  Widget _buildImportInProgress(BuildContext context, ImportFlashcardsProgressTracker progressTracker) {
    if (progressTracker.progress == 0) {
      return _buildWaiting();
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            MyAppLocalizations.of(context).importFlashcardsInProgressTitle,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            MyAppLocalizations.of(context).importFlashcardsWarningMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).errorColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 16,
          ),
          LinearProgressIndicator(
            value: progressTracker.progress,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            minHeight: 8,
          ),
          SizedBox(
            height: 4,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              MyAppLocalizations.of(context).importFlashcardsProgressTracker(
                  progressTracker.currentFlashcard, progressTracker.flashcardsToImportCount),
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportFinished(BuildContext context, ImportFlashcardsProgressTracker progressTracker) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          MyAppLocalizations.of(context).importFlashcardsFinishedTitle,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(MyAppLocalizations.of(context).importedFlashcards),
                trailing: Text(progressTracker.importedFlashcardsCount.toString()),
              ),
              ListTile(
                title: Text(MyAppLocalizations.of(context).duplicatedFlashcards),
                trailing: Text(progressTracker.duplicatedFlashcards.toString()),
              ),
              ListTile(
                title: Text(MyAppLocalizations.of(context).importErrors),
                trailing: Text(progressTracker.importFlashcardsErrors.toString()),
              ),
              ListTile(
                title: Text(MyAppLocalizations.of(context).processedFlashcards),
                trailing: Text(progressTracker.flashcardsToImportCount.toString()),
              )
            ],
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: Text(MyAppLocalizations.of(context).close))
      ],
    );
  }
}
