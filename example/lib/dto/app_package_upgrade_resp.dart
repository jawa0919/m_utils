class AppPackageUpgradeResp {
  final String? version;
  final int? upgradeFlag;
  final String? storagePath;
  final String? content;
  final String? title;
  final String? hashVal;

  const AppPackageUpgradeResp({
    this.version,
    this.upgradeFlag,
    this.storagePath,
    this.content,
    this.title,
    this.hashVal,
  });

  factory AppPackageUpgradeResp.fromJson(Map<String, dynamic> json) =>
      AppPackageUpgradeResp(
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

  AppPackageUpgradeResp copyWith({
    String? version,
    int? upgradeFlag,
    String? storagePath,
    String? content,
    String? title,
    String? hashVal,
  }) => AppPackageUpgradeResp(
    version: version ?? this.version,
    upgradeFlag: upgradeFlag ?? this.upgradeFlag,
    storagePath: storagePath ?? this.storagePath,
    content: content ?? this.content,
    title: title ?? this.title,
    hashVal: hashVal ?? this.hashVal,
  );

  @override
  String toString() {
    return 'AppPackageUpgradeResp{version: $version, upgradeFlag: $upgradeFlag, storagePath: $storagePath, content: $content, title: $title, hashVal: $hashVal}';
  }
}
