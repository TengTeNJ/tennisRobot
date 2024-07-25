import 'dart:async';

class EventBus {
  static final _instance = EventBus._internal();
  factory EventBus() => _instance;

  EventBus._internal();

  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  void sendEvent(dynamic event) {
    _controller.sink.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

final eventBus = EventBus();
