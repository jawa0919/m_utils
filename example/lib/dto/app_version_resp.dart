class AppVersionResp {
  final String? version;
  final int? upgradeFlag;
  final String? storagePath;
  final String? content;
  final String? title;
  final String? hashVal;

  const AppVersionResp({
    this.version,
    this.upgradeFlag,
    this.storagePath,
    this.content,
    this.title,
    this.hashVal,
  });

  factory AppVersionResp.fromJson(Map<String, dynamic> json) => AppVersionResp(
    version: json['version'],
    upgradeFlag: json['upgradeFlag'],
    storagePath: json['storagePath'],
    content: json['content'],
    title: json['title'],
    hashVal: json['hashVal'],
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'upgradeFlag': upgradeFlag,
    'storagePath': storagePath,
    'content': content,
    'title': title,
    'hashVal': hashVal,
  };

  @override
  String toString() {
    return 'AppVersionResp{version: $version, upgradeFlag: $upgradeFlag, storagePath: $storagePath, content: $content, title: $title, hashVal: $hashVal}';
  }
}
