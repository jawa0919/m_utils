class LoginUserResp {
  final String? id;
  final String? email;
  final String? nickname;
  final String? surname;
  final String? name;
  final String? avatar;
  final int? isSubscribe;
  final String? subscribeExpireTime;
  final String? lastLogin;
  final String? lastLoginIp;
  final String? createTime;
  final String? updateTime;
  final String? token;

  const LoginUserResp({
    this.id,
    this.email,
    this.nickname,
    this.surname,
    this.name,
    this.avatar,
    this.isSubscribe,
    this.subscribeExpireTime,
    this.lastLogin,
    this.lastLoginIp,
    this.createTime,
    this.updateTime,
    this.token,
  });

  factory LoginUserResp.fromJson(Map<String, dynamic> json) => LoginUserResp(
    id: json['id'],
    email: json['email'],
    nickname: json['nickname'],
    surname: json['surname'],
    name: json['name'],
    avatar: json['avatar'],
    isSubscribe: json['isSubscribe'],
    subscribeExpireTime: json['subscribeExpireTime'],
    lastLogin: json['lastLogin'],
    lastLoginIp: json['lastLoginIp'],
    createTime: json['createTime'],
    updateTime: json['updateTime'],
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,

    'email': email,
    'nickname': nickname,
    'surname': surname,
    'name': name,
    'avatar': avatar,

    'isSubscribe': isSubscribe,
    'subscribeExpireTime': subscribeExpireTime,

    'lastLogin': lastLogin,
    'lastLoginIp': lastLoginIp,
    'createTime': createTime,
    'updateTime': updateTime,
    'token': token,
  };

  @override
  String toString() {
    return 'LoginUserResp{id: $id, email: $email, nickname: $nickname, surname: $surname, name: $name, avatar: $avatar, subscribeExpireTime: $subscribeExpireTime, lastLogin: $lastLogin, lastLoginIp: $lastLoginIp, createTime: $createTime, updateTime: $updateTime, token: $token}';
  }
}
