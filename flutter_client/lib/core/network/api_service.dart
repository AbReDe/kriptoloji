import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';

  Future<bool> MesajGonder({
    required String gonderen,
    required String sifreliIcerik,
    required String yontem,
  }) async {
    final url = Uri.parse('$_baseUrl/mesaj_gonder');

    print('--- Mesaj Gönderme İsteği Başladı ---');
    print('Gönderen: $gonderen | Yöntem: $yontem | İçerik: $sifreliIcerik');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'gonderen': gonderen,
          'sifreli_icerik': sifreliIcerik,
          'yontem': yontem,
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Mesaj başarıyla sunucuya iletildi!');
        return true;
      } else {
        print('❌ Sunucu hatası! Kod: ${response.statusCode}');
        print('Hata Mesajı: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Bağlantı hatası oluştu: $e');
      return false;
    }
  }

  Future<List<dynamic>> mesajlariAl() async {
    final url = Uri.parse('$_baseUrl/mesajlari_al');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print("📥 Mesajlar çekildi. Toplam mesaj sayısı: ${data.length}");
        return data;
      } else {
        print("❌ Mesajları çekerken hata: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("⚠️ API'ye bağlanılamadı (mesajlariAl): $e");
      return [];
    }
  }
}