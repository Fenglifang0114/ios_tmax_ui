import 'package:t_max/data/reccount_data.dart';
import 'package:t_max/data/recprice_data.dart';
import 'package:t_max/data/recwt_data.dart';

const int recTypeWt = 1;
const int recTypeCount = 2;
const int recTypePrice = 3;

/*
RecData 报表数据记录
*/

class RecData {
  int? recType;
  Object? data;

  RecData(this.recType, this.data);

  RecData.fromJson(Map<String, dynamic> json) {
    recType = json['recType'];
    if (recType == recTypeWt) {
      data = json['data'] != null ? RecWt.fromJson(json['data']) : null;
    } else if (recType == recTypeCount) {
      data = json['data'] != null ? RecCount.fromJson(json['data']) : null;
    } else {
      data = json['data'] != null ? RecPrice.fromJson(json['data']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recType'] = recType;
    if (this.data != null) {
      if (recType == recTypeWt) {
        data['data'] = (data as RecWt).toJson();
      } else if (recType == recTypeCount) {
        data['data'] = (data as RecCount).toJson();
      } else {
        data['data'] = (data as RecPrice).toJson();
      }
    }
    return data;
  }
}

RecData myRecData = RecData(1, {});
