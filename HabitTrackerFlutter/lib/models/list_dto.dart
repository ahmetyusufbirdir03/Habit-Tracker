class ListDto<T> {
  final List<T> items;

  ListDto(this.items);

  factory ListDto.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final List<dynamic> jsonList = json['data'] as List<dynamic>? ?? [];
    final items = jsonList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList();
    return ListDto(items);
  }
}