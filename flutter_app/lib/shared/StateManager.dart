
import 'package:exam_app/domain/Entity.dart';

class StateManager {

  static remove(List <Entity> items, Entity item) {
    int index = -1;
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == item.id) {
        index = i;
      }
    }
    if (index > -1) {
      items.removeAt(index);
    }
    return items;
  }

  static update(List <Entity> items, Entity newItem) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == newItem.id) {
        items[i] = newItem;
      }
    }
    return StateManager.getTop(items);
  }


  static add(List <Entity> items, Entity item) {
    items.add(item);
    return items;
  }

  static getTop(List <Entity> items) {
    items.sort((a, b) => a.rating - b.rating);
    items = items.take(10).toList();
    return items;
  }
}