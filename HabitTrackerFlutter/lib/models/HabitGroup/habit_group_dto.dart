class HabitGroupListDto {
  final List<HabitGroupDto> habitGroups;
  HabitGroupListDto(this.habitGroups);

  factory HabitGroupListDto.fromJson(Map<String, dynamic> json){
    final data = json['data'];
    final List jsonGroups = (data is List) ? data : [];
    return HabitGroupListDto(jsonGroups.map((e) => HabitGroupDto.fromJson(e)).toList());
  }
}

class HabitGroupDto {
  String? id;
  String? name;
  DateTime? createdDate;

  HabitGroupDto({this.id, this.name});

  HabitGroupDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdDate =  DateTime.parse(json['createdDate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}