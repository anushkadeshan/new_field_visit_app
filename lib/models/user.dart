class User {
  int id;
  String name;
  String email;
  String emailVerifiedAt;
  String currentTeamId;
  String profilePhotoPath;
  String createdAt;
  String updatedAt;
  int active;
  int branchId;
  String welcomeValidUntil;
  int phone;
  String branches;
  String dsds;
  String gnds;
  String deletedAt;
  String lastSeen;
  String profilePhotoUrl;

  User(
      {this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.currentTeamId,
        this.profilePhotoPath,
        this.createdAt,
        this.updatedAt,
        this.active,
        this.branchId,
        this.welcomeValidUntil,
        this.phone,
        this.branches,
        this.dsds,
        this.gnds,
        this.deletedAt,
        this.lastSeen,
        this.profilePhotoUrl});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    currentTeamId = json['current_team_id'];
    profilePhotoPath = json['profile_photo_path'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    active = json['active'];
    branchId = json['branch_id'];
    welcomeValidUntil = json['welcome_valid_until'];
    phone = json['phone'];
    branches = json['branches'];
    dsds = json['dsds'];
    gnds = json['gnds'];
    deletedAt = json['deleted_at'];
    lastSeen = json['last_seen'];
    profilePhotoUrl = json['profile_photo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['current_team_id'] = this.currentTeamId;
    data['profile_photo_path'] = this.profilePhotoPath;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['active'] = this.active;
    data['branch_id'] = this.branchId;
    data['welcome_valid_until'] = this.welcomeValidUntil;
    data['phone'] = this.phone;
    data['branches'] = this.branches;
    data['dsds'] = this.dsds;
    data['gnds'] = this.gnds;
    data['deleted_at'] = this.deletedAt;
    data['last_seen'] = this.lastSeen;
    data['profile_photo_url'] = this.profilePhotoUrl;
    return data;
  }
}