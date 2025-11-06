import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:5000';

  Future<bool> MesajGonder({
    required String  gonderen,
    required String sifreliIcerik,
    required String yontem,
})async{
    final url = Uri.parse('$_baseUrl/mesaj_gonder');
    print('api servisteyim gonderen: $gonderen , icerik: $sifreliIcerik , yontem: $yontem');
    print("bence hala daha sorunnvar amk");
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:json.encode({
          'gonderen': gonderen,
          'sifreli_icerik':sifreliIcerik,
          'yontem':yontem,
        }),
      );

      if (response.statusCode==201){
        print('afferinlan kareta gonderdin');
        return true;
      }else{
        print('sunucu boka gitti ====== ${response.body}');
        return false;
      }
    }catch(e){
      print('baglanti hatasi balikom $e');
      return false;
    }
  }//mesaj gonder fonk sonu


  Future<List<dynamic>> mesajlariAl() async {
    final url = Uri.parse('$_baseUrl/mesajlari_al');

    try {
      final response = await http.get(url);

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("Mesajlar başarıyla alındı: $data");
        return data;
      } else {
        print("mesaji cekmedin agaa: ${response.body}");
        return [];
      }
    } catch (e) {
      print("aga baglanamadik la : $e");
      return [];
    }
  }








}//api service