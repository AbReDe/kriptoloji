import 'package:flutter/material.dart';
import 'package:kriptoloji/core/network/api_service.dart';
import 'package:kriptoloji/core/crypto/crypto_service.dart';

class chatScreen extends StatefulWidget {
  const chatScreen({Key? key}) : super(key: key);

  @override
  State<chatScreen> createState() => _chatScreenState();
}


class _chatScreenState extends State<chatScreen> {


  final TextEditingController _mesajController = TextEditingController();
  final ApiService _apiService = ApiService();
  final CryptoService _cryptoService = CryptoService();


  String _seciliYontem = 'Sezar';
  final List<String> _sifrelemeYontemleri = ['Sezar', 'Affine', 'Substitution', 'Vigenere'];

  bool _isLoading = false;

  @override
  void dispose() {
    _mesajController.dispose();
    super.dispose();
  }



  void _mesajGonder() async {
    if (_mesajController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String duzMetin = _mesajController.text;
    String sifreliMetin = '';

    if (_seciliYontem == 'Sezar') {
      sifreliMetin = _cryptoService.sezarSifrele(duzMetin, 3);
    } else {
      sifreliMetin = duzMetin;
      print('buraya ekleyecez devamini');
      //burayi unutmaa buraya devami gelicek haaaaaaaa
      //aaaaaaaaaaaaaaaaaaaaaaaaa
      //aaaaaaaaaaaaaaaaaaa
    }

    bool basarili = await _apiService.MesajGonder(
        gonderen: 'FlutterKullanicisi',
        sifreliIcerik: sifreliMetin,
        yontem: _seciliYontem);


    if (!mounted) return;


    setState(() {
      _isLoading = false;
    });

    if (basarili) {
      _mesajController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('helalllan yusufi'),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('fuck yaaa'),
            backgroundColor: Colors.red),
      );
    }
  }// mesaj gonder sonu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mesajlasma'),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(child: Text('gelen mesajlar burada')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    // Yazım hatası düzeltildi: _mesajControler -> _mesajController
                    controller: _mesajController,
                    decoration: const InputDecoration(
                      hintText: 'mesaj yazsana',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _seciliYontem,
                  items: _sifrelemeYontemleri.map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _seciliYontem = newValue!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                _isLoading
                    ? const CircularProgressIndicator()
                    : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _mesajGonder,
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}