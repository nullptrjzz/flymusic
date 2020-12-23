import 'package:event_bus/event_bus.dart';
import 'package:flymusic/util/play_list.dart';

EventBus eventBus = EventBus();

EventBus eventBusSync = EventBus(sync: true);

class AppInitEvent {
  String state;
  bool finished;

  AppInitEvent(this.state, this.finished);
}

class PlayListLoadEvent {
  String id;
  PlayListItem item;
  bool addFirst = true;

  PlayListLoadEvent(this.id, this.item, [this.addFirst]);
}