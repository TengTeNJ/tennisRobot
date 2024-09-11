class PickupBallModel {
  String id = '0';
  String pickupBallNumber = '0'; // 捡球数量
  String time = ''; // 时间

   PickupBallModel({required this.pickupBallNumber,required this.time});


  factory PickupBallModel.modelFromJson(Map<String, dynamic> json) {
    PickupBallModel model =  PickupBallModel(
      pickupBallNumber: json['pickupBallNumber'] ?? '0',
      time: json['time'] ?? '0',
    );
    return model;
  }

  Map<String, dynamic> toJson() =>
      <String, dynamic>{
        'pickupBallNumber': this.pickupBallNumber,
        'time': this.time,
        'id': this.id,
      };
}