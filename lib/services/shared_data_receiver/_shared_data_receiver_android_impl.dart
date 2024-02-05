part of 'shared_data_receiver.dart';

class _SharedDataReceiverAndroidImpl implements SharedDataReceiver {
  static const platform = MethodChannel(ANDROID_METHOD_CHANNEL_NAME);
  static const eventChannel = EventChannel(ANDROID_EVENT_CHANNEL_NAME);
  static Stream<SharedDataReceivedType>? _streamInstance;

  @override
  Future<void> discard() async {
    await platform.invokeMethod<bool>('discardSharedContent');
  }

  @override
  Future<bool> hasData() async {
    var result = await platform.invokeMethod<bool>('hasSharedContent');
    return result!;
  }

  @override
  Future<List<String>> receiveFileLines() async {
    try {
      var result = await platform.invokeMethod<List>('restoreSharedContent');
      return List<String>.from(result!);
    } on PlatformException catch (platformException) {
      throw handlerPlatformException(platformException);
    }
  }

  @override
  bool get isAvailableInCurrentPlatform => true;

  @override
  Stream<SharedDataReceivedType> dataReceivedStream() {
    return _streamInstance ??= eventChannel.receiveBroadcastStream().map((event) {
      if (event == AndroidEventChannelEventsCodes.INTENT_WITH_IMPORTABLE_DATA) {
        return SharedDataReceivedType.FILE_LINES;
      }
      return SharedDataReceivedType.UNKNOWN;
    });
  }
}
