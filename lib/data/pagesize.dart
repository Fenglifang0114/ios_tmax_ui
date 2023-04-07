class PageSize {
  String size;

  PageSize(this.size);
  PageSize.fromJson(Map<String, dynamic> json) : size = json['size'];
  Map<String, dynamic> toJson() {
    return {
      'size': size,
    };
  }
}

PageSize myPageSize = PageSize("");
