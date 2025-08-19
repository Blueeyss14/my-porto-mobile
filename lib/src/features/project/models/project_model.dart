class ProjectModel {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final bool isPinned;
  final List<ImageItem> imageUrl;
  final List<String> tags;
  final String thumbnail;
  final List<Contributor> contributing;
  final List<Resource> resources;

  ProjectModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.isPinned,
    required this.imageUrl,
    required this.tags,
    required this.thumbnail,
    required this.contributing,
    required this.resources,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isPinned: json['is_pinned'] ?? '',
      imageUrl: (json['image_url'] as List<dynamic>)
          .map((e) => ImageItem.fromJson(e))
          .toList(),
      tags: List<String>.from(json['tags']),
      thumbnail: json['thumbnail'],
      contributing: (json['contributing'] as List<dynamic>)
          .map((e) => Contributor.fromJson(e))
          .toList(),
      resources: (json['resources'] as List<dynamic>)
          .map((e) => Resource.fromJson(e))
          .toList(),
    );
  }
}

class ImageItem {
  final String url;

  ImageItem({required this.url});

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(url: json['url']);
  }
}

class Contributor {
  final String name;
  final String link;

  Contributor({required this.name, required this.link});

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(name: json['name'], link: json['link']);
  }
}

class Resource {
  final String name;
  final String link;

  Resource({required this.name, required this.link});

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(name: json['name'], link: json['link']);
  }
}
