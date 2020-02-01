class Entity {
  int id, time, rating;
  String name, details, type;

  Entity({this.id, this.name, this.details, this.time, this.type, this.rating});

  String toString() {
    return "Id: " + this.id.toString() + "\n" +
      "Name: " + this.name + "\n" +
      "Details: " + this.details.toString() + "\n" +
      "Time: " + this.time.toString() + "\n" +
      "Type: " + this.type + "\n" +
      "Rating: " + this.rating.toString() + "\n";
  }

  Map <String, dynamic> toMap() {
    Map <String, dynamic> map = new Map();
    map['id'] = this.id;
    map['name'] = this.name;
    map['details'] = this.details;
    map['time'] = this.time;
    map['type'] = this.type;
    map['rating'] = this.rating;
    return map;
  }

  static fromMap(Map <String, dynamic> map) {
    return new Entity(
      id: map['id'],
      name: map['name'],
      details: map['details'],
      time: map['time'],
      type: map['type'],
      rating: map['rating']
    );
  }

  static fromMapList(List <Map <String, dynamic> > list) {
    List <Entity> entities = List();
    list.forEach((item) => entities.add(Entity.fromMap(item)));
    return entities;
  }
}