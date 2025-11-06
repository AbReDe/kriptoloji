import 'package:flutter/material.dart';
import 'package:kriptoloji/core/network/api_service.dart';
import 'package:kriptoloji/core/crypto/crypto_service.dart';
import '../../core/model/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _mesajController = TextEditingController();
  final ApiService _apiService = ApiService();
  final CryptoService _cryptoService = CryptoService();

  String _seciliYontem = 'Sezar';
  final List<String> _sifrelemeYontemleri = ['Sezar', 'Affine', 'Substitution', 'playfair'];
  List<Message> _mesajlar = [];

  bool _mesajlarYukleniyor = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mesajlariCek();
  }

  @override
  void dispose() {
    _mesajController.dispose();
    super.dispose();
  }

  void _mesajGonder() async {
    if (_mesajController.text.isEmpty) return;

    setState(() => _isLoading = true);

    String duzMetin = _mesajController.text;
    String sifreliMetin = '';

    switch (_seciliYontem) {
      case 'Sezar':
        sifreliMetin = _cryptoService.sezarSifrele(duzMetin, 3);
        break;

      case 'Affine':
        sifreliMetin = _cryptoService.affineSifrele(duzMetin, 5, 8);
        break;



      case 'Playfair':
        const key = "SECRET";
        sifreliMetin =
            _cryptoService.playfairSifrele(duzMetin, key);
        break;
    }

    bool basarili = await _apiService.MesajGonder(
      gonderen: 'FlutterKullanicisi',
      sifreliIcerik: sifreliMetin,
      yontem: _seciliYontem,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (basarili) {
      _mesajController.clear();
      _mesajlariCek();
    }
  }

  Future<void> _mesajlariCek() async {
    setState(() => _mesajlarYukleniyor = true);

    final gelenMesajlarRaw = await _apiService.mesajlariAl();
    final List<Message> cozulmusMesajlar = [];

    for (var eleman in gelenMesajlarRaw) {
      final msg = Message.fromJson(eleman);

      String cozulmusMetin = '';

      switch (msg.yontem) {
        case 'Sezar':
          cozulmusMetin = _cryptoService.sezarCoz(msg.sifreliIcerik, 3);
          break;
        case 'Affine':
          cozulmusMetin = _cryptoService.affineCoz(msg.sifreliIcerik, 5, 8);
          break;

        case 'Playfair':
          const key = "SECRET";
          cozulmusMetin =
              _cryptoService.playfairCoz(msg.sifreliIcerik, key);
          break;
        default:
          cozulmusMetin = msg.sifreliIcerik; // yöntemi tanımlanmamışsa
      }

      // Çözülmüş metni yeni alana yazalım
      msg.cozulmusIcerik = cozulmusMetin;
      cozulmusMesajlar.add(msg);
    }

    setState(() {
      _mesajlar = cozulmusMesajlar;
      _mesajlarYukleniyor = false;
    });
  }


  Widget _mesajBalon(Message mesaj) {
    bool benimMesajim = mesaj.gonderen == "FlutterKullanicisi";

    return Align(
      alignment: benimMesajim ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: benimMesajim ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
          benimMesajim ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              mesaj.sifreliIcerik,
              style: TextStyle(
                fontSize: 16,
                color: benimMesajim ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              mesaj.yontem,
              style: TextStyle(
                fontSize: 12,
                color: benimMesajim ? Colors.white70 : Colors.black54,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlaşma'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _mesajlariCek),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _mesajlarYukleniyor
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              reverse: true, // En yeni mesaj üstte
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                return _mesajBalon(_mesajlar[index]);
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _mesajlarYukleniyor
                      ? Center(child: CircularProgressIndicator())
                      : _mesajlar.isEmpty
                      ? Center(child: Text("Hiç mesaj yok la"))
                      : ListView.builder(
                    reverse: true,
                    itemCount: _mesajlar.length,
                    itemBuilder: (context, index) {
                      final mesaj = _mesajlar[index];

                      return Align(
                        alignment: mesaj.gonderen == "FlutterKullanicisi"
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mesaj.gonderen,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                              ),
                              SizedBox(height: 4),
                              Text(
                                mesaj.cozulmusIcerik,
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                mesaj.timestamp,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _seciliYontem,
                  items: _sifrelemeYontemleri
                      .map((y) => DropdownMenuItem(
                    value: y,
                    child: Text(y),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _seciliYontem = v!),
                ),
                _isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _mesajGonder,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
