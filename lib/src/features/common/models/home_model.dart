class HomeModel {
  String page;
  String route;

  HomeModel(this.page, this.route);

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(json['page'] ?? '', json['route'] ?? '');
  }
}
