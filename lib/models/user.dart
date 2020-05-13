class User {
  User({this.uid});
  String uid ;
  String name ;
  String imageUrl;

   User.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        name = json['name'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> toJson() =>  
    {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
    };
}