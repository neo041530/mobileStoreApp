class MemberLogin{
  final String Mid;
  final String Mname;
  final String Vid;

  MemberLogin(this.Mid, this.Mname,this.Vid);

  factory MemberLogin.fromJson(dynamic json) => MemberLogin(
    json["objectId"].toString(),
    json["Account"].toString(),
    json["haveCard"].toString(),
  );
}

class Totalcards{
  final String vid;
  final String name;
  final String place;
  final String phone;
  final String photo;

  Totalcards(this.vid, this.name, this.place,this.phone,this.photo);

  factory Totalcards.fromJson(dynamic json) => Totalcards(
    json["objectId"].toString(),
    json["V_name"].toString(),
    json["V_place"].toString(),
    json["V_phone"].toString(),
    json["V_photo"].toString(),
  );
}

class cardsdetail{
  final String vid;
  final String name;
  final String daytime;
  final String phone;
  final String place;
  final String introduce;
  final String photo;
  final String lng;
  final String lat;
  final String weektime1;
  final String weektime2;
  final String weektime3;
  final String weektime4;
  final String weektime5;
  final String weektime6;
  final String weektime7;

  cardsdetail(this.vid, this.name, this.daytime, this.phone, this.place, this.introduce,this.photo,
      this.lng,this.lat,this.weektime1, this.weektime2, this.weektime3, this.weektime4, this.weektime5, this.weektime6, this.weektime7);

  factory cardsdetail.fromJson(dynamic json) => cardsdetail(
    json["objectId"].toString(),
    json["V_name"].toString(),
    json["V_daytime"].toString(),
    json["V_phone"].toString(),
    json["V_place"].toString(),
    json["V_introduce"].toString(),
    json["V_photo"].toString(),
    json["V_lng"].toString(),
    json["V_lat"].toString(),
    json["V_week1"].toString(),
    json["V_week2"].toString(),
    json["V_week3"].toString(),
    json["V_week4"].toString(),
    json["V_week5"].toString(),
    json["V_week6"].toString(),
    json["V_week7"].toString(),
  );
}
class Favorite{
  final String VID;

  Favorite(this.VID);

  factory Favorite.fromJson(dynamic json) => Favorite(
    json["V_ID"].toString(),
  );
}
class Menu{
  final String name;
  final String price;
  final String photo;

  Menu(this.name, this.price,this.photo);

  factory Menu.fromJson(dynamic json) => Menu(
    json["M_name"].toString(),
    json["M_price"].toString(),
    json["M_photo"].toString(),
  );

}
class Version{
  final String number;
  final String File;

  Version(this.number, this.File);

  factory Version.fromJson(dynamic json) => Version(
    json["Number"].toString(),
    json["File"].toString(),

  );

}
class Favoriteobjectid{
  final String objectId;

  Favoriteobjectid(this.objectId);

  factory Favoriteobjectid.fromJson(dynamic json) => Favoriteobjectid(
    json["objectId"].toString(),
  );
}

class ckFavorite{
  final String Favorite;

  ckFavorite(this.Favorite);

  factory ckFavorite.fromJson(dynamic json) => ckFavorite(
    json["Favorite"].toString(),
  );
}

class latlng{
  final String lat;
  final String lng;

  latlng(this.lat, this.lng);

  factory latlng.fromJson(dynamic json) => latlng(
    json["V_lat"].toString(),
    json["V_lng"].toString(),
  );
}