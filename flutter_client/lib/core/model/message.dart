class Message {
  final int id;
  final String gonderen;
  final String sifreliIcerik;
  final String yontem;
  final String timestamp;
  String cozulmusIcerik = "";


  Message({
    required this.id,
    required this.gonderen,
    required this.sifreliIcerik,
    required this.yontem,
    required this.timestamp,
  });


  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      gonderen: json['gonderen'],
      sifreliIcerik: json['sifreli_icerik'],
      yontem: json['yontem'],
      timestamp: json['timestamp'],
    );
  }
}
