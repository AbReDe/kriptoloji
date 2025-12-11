class Message {
  final int id;
  final String gonderen;
  final String sifreliIcerik;
  final String yontem;
  final String timestamp;

  // Bu alan veritabanından gelmez, uygulama içinde şifreyi çözünce doldururuz.
  String cozulmusIcerik = "";

  Message({
    required this.id,
    required this.gonderen,
    required this.sifreliIcerik,
    required this.yontem,
    required this.timestamp,
  });

  // JSON'dan nesne oluştururken (Python'dan gelen veriyi burası karşılar)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      gonderen: json['gonderen'] ?? 'Bilinmiyor',
      // DİKKAT: Python 'sifreli_icerik' gönderiyor, biz burada onu alıp değişkenimize atıyoruz.
      sifreliIcerik: json['sifreli_icerik'] ?? '',
      yontem: json['yontem'] ?? 'Sezar',
      timestamp: json['timestamp'] ?? '',
    );
  }

  // Nesneyi JSON'a çevirirken (Gerekirse diye ekledim)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gonderen': gonderen,
      'sifreli_icerik': sifreliIcerik,
      'yontem': yontem,
      'timestamp': timestamp,
    };
  }
}