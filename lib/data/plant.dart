

enum Cycles{id,type,cycle,startDate,init}
enum CycleType{watering, repotting}

class Plant{

  Plant({this.id, this.pinned, this.name, this.type, this.date, this.note, this.cycles});

  final int? id;
  final bool? pinned;
  final String? name;
  final String? type;
  final String? date;
  final String? note;
  final List? cycles;

}
