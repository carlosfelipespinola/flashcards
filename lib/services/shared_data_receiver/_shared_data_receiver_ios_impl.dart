part of 'shared_data_receiver.dart';

class _SharedDataReceiverIosImpl implements SharedDataReceiver {
  @override
  Future<void> discard() {
    // TODO: implement discard
    throw UnimplementedError();
  }

  @override
  Future<bool> hasData() {
    // TODO: implement hasData
    throw UnimplementedError();
  }

  @override
  bool get isAvailableInCurrentPlatform => false;

  @override
  Future<List<String>> receiveFileLines() {
    // TODO: implement receiveFileLines
    throw UnimplementedError();
  }

  @override
  Stream<SharedDataReceivedType> dataReceivedStream() {
    // TODO: implement listen
    throw UnimplementedError();
  }
}
