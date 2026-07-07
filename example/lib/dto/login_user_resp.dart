class LoginUserResp {
  final String? id;
  final String? account;
  final String? password;
  final String? phone;
  final String? surname;
  final String? name;
  final String? nickname;
  final String? avatar;
  final String? email;
  final int? level;
  final String? lastLogin;
  final String? lastLoginIp;
  final String? token;

  const LoginUserResp({
    this.id,
    this.account,
    this.password,
    this.phone,
    this.surname,
    this.name,
    this.nickname,
    this.avatar,
    this.email,
    this.level,
    this.lastLogin,
    this.lastLoginIp,
    this.token,
  });

  factory LoginUserResp.fromJson(Map<String, dynamic> json) => LoginUserResp(
    id: json['id'],
    account: json['account'],
    password: json['password'],
    phone: json['phone'],
    surname: json['surname'],
    name: json['name'],
    nickname: json['nickname'],
    avatar: json['avatar'],
    email: json['email'],
    level: json['level'],
    lastLogin: json['lastLogin'],
    lastLoginIp: json['lastLoginIp'],
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'account': account,
    'password': password,
    'phone': phone,
    'surname': surname,
    'name': name,
    'nickname': nickname,
    'avatar': avatar,
    'email': email,
    'level': level,
    'lastLogin': lastLogin,
    'lastLoginIp': lastLoginIp,
    'token': token,
  };

  @override
  String toString() {
    return 'LoginUserResp{id: $id, account: $account, password: $password, phone: $phone, surname: $surname, name: $name, nickname: $nickname, avatar: $avatar, email: $email, level: $level, lastLogin: $lastLogin, lastLoginIp: $lastLoginIp, token: $token}';
  }
}
