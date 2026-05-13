import 'package:t_max/data/conninfobt_data.dart';
import 'package:t_max/data/conn_info_net_data.dart';
import 'package:t_max/data/conn_info_sport_data.dart';

const int connTypeSport = 1;
const int connTypeNet = 2;
const int connTypeBt = 3;

class ConnInfo {
  String? modelName;
  String? scaSn;
  String? description;
  String? id;
  int? mediaType;
  Object? media;

  ConnInfo(this.modelName, this.scaSn, this.description, this.id,
      this.mediaType, this.media);

  ConnInfo.fromJson(Map<String, dynamic> json) {
    modelName = json['modelName'];
    scaSn = json['scaSn'];
    description = json['description'];
    id = json['id'];
    mediaType = json['mediaType'];
    if (mediaType == connTypeSport) {
      media =
          json['media'] != null ? ConnInfoSport.fromJson(json['media']) : null;
    } else if ((mediaType == connTypeNet)) {
      media =
          json['media'] != null ? ConnInfoNet.fromJson(json['media']) : null;
    } else {
      media = json['media'] != null ? ConnInfoBt.fromJson(json['media']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modelName'] = modelName;
    data['scaSn'] = scaSn;
    data['description'] = description;
    data['id'] = id;
    data['mediaType'] = mediaType;
    if (mediaType == connTypeSport) {
      data['media'] = (media as ConnInfoSport).toJson();
    } else if ((mediaType == connTypeNet)) {
      data['media'] = (media as ConnInfoNet).toJson();
    } else {
      data['media'] = (media as ConnInfoBt).toJson();
    }

    return data;
  }
}

ConnInfo myConnInfo = ConnInfo("", "", "", "", 0, {});














// import 'media_data.dart';

// const int connTypeSport = 1;
// const int connTypeNet = 2;
// const int connTypeBt = 3;

// class Infolist {
//   String? modelName;
//   String? scaSn;
//   String? description;
//   String? id;
//   int? mediaType;
//   Media? media;
  
//   Infolist(this.modelName, this.scaSn, this.description, this.id,
//       this.mediaType, this.media);

//   Infolist.fromJson(Map<String, dynamic> json) {
//     modelName = json['modelName'];
//     scaSn = json['scaSn'];
//     description = json['description'];
//     id = json['id'];
//     mediaType = json['mediaType'];
//     media = json['media'] != null ? Media.fromJson(json['media']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['modelName'] = modelName;
//     data['scaSn'] = scaSn;
//     data['description'] = description;
//     data['id'] = id;
//     data['mediaType'] = mediaType;
//     if (media != null) {
//       data['media'] = media!.toJson();
//     }
//     return data;
//   }
// }

// Infolist myInfolist = Infolist("", "", "", "", 0, myMedia);
