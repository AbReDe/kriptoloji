import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiService {
  static const String _baseUrl= 'http://192.168.1.37.5000';








  Future<bool> MesajGonder({
    required String  gonderen,
    required String sifreliIcerik,
    required String yontem,
})async{
    final url = Uri.parse('$_baseUrl/mesaj_gonder');
    try{
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-T'},
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
  }//asyc mesaj gonder fonk sonu










Future<List<dynamic>> mesajlariAl()async {
  final url = Uri.parse('$_baseUrl/mesajlari_al');

  try {
    final response = await http.get(url);
    if (response == 200) {
      return json.decode(response.body);
    } else {
      print(' mesaji cekmedin agaa============ ${response.body}');
      return [];
    }
  } catch (e) {
    print('aga baglanamadik la : $e');
    return [];
  }
}// mesajlari al sonu da








}//api service