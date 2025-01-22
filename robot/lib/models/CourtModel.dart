//import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

class Courtmodel {
  String courtIndex = '0'; //索引
  String imageAsset = ''; //
  Uint8List screenshot;

  String courtName = '網球場'; //
  String courtAddress = '中南體育中心'; //
  String courtDate = '2024-12-29'; //

 Courtmodel(this.courtIndex,this.screenshot,this.imageAsset,this.courtName,this.courtAddress,this.courtDate);

 factory Courtmodel.modelFromJson(Map<String, dynamic> json) {
   Courtmodel model = Courtmodel(json['courtIndex'],json['screenshot'],json['imageAsset'], json['courtName'],
       json['courtAddress'], json['courtDate']);
   return model;
 }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'courtIndex' : this.courtIndex,
        'imageAsset': this.imageAsset,
        'screenshot': this.screenshot,
        'courtName': this.courtName,
        'courtAddress': this.courtAddress,
        'courtDate': this.courtDate,
      };

}