import 'package:flutter/material.dart';
import 'package:kriptoloji/core/network/api_service.dart';
import 'package:kriptoloji/core/crypto/crypto_service.dart';
import '../../core/model/message.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;

  const ChatScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _mesajController = TextEditingController();
  final ApiService _apiService = ApiService();
  final CryptoService _cryptoService = CryptoService();

  String _seciliYontem = 'Sezar';
  final List<String> _sifrelemeYontemleri = [
    'Sezar',
    'Affine',
    'Playfair',
    'Substitution',
    'Vigenere',
    'Rail Fence',
    'Route',
    'Columnar Transposition',
    'Polybius',
    'Hill',
    'Vernam',
    'AES (Lib)',
    'AES (Manual)',
    'DES (Manual)',
  ];
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
        sifreliMetin = _cryptoService.playfairSifrele(duzMetin, key);
        break;

      case 'Substitution':
        const key = "QWERTYUIOPASDFGHJKLZXCVBNM";
        sifreliMetin = _cryptoService.substitutionSifrele(duzMetin, key);
        break;

      case 'Vigenere':
        const key = "ANAHTAR";
        sifreliMetin = _cryptoService.vigenereSifrele(duzMetin, key);
        break;

      case 'Rail Fence':
        int raySayisi = 3;
        sifreliMetin = _cryptoService.railFenceSifrele(duzMetin, raySayisi);
        break;

      case 'Route':
        int kolonSayisi = 4;
        sifreliMetin = _cryptoService.routeSifrele(duzMetin, kolonSayisi);
        break;

      case 'Columnar Transposition':
        const key = "GERMAN";
        sifreliMetin = _cryptoService.columnarTranspositionSifrele(duzMetin, key);
        break;

      case 'Polybius':
        sifreliMetin = _cryptoService.polybiusSifrele(duzMetin);
        break;

      case 'Hill':
        const key = "GYBNQKURP";
        sifreliMetin = _cryptoService.hillSifrele(duzMetin, key);
        break;

      case 'Vernam':
        const key = "RANDOMKEYGENERATEDFOREXAMPLE";
        sifreliMetin = _cryptoService.vernamSifrele(duzMetin, key);
        break;
      case 'AES (Lib)':
        sifreliMetin = _cryptoService.aesLibSifrele(duzMetin);
        break;

      case 'AES (Manual)':
        const key = "MYSECRETKEYMANUAL";
        sifreliMetin = _cryptoService.aesManualSifrele(duzMetin, key);
        break;

      case 'DES (Manual)':
        const key = "KEYDES88";
        sifreliMetin = _cryptoService.desManualSifrele(duzMetin, key);
        break;

      default:
        sifreliMetin = duzMetin;
    }

    bool basarili = await _apiService.MesajGonder(
      gonderen: widget.currentUser,
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

    try {
      final gelenMesajlarRaw = await _apiService.mesajlariAl();
      final List<Message> cozulmusMesajlar = [];

      for (var eleman in gelenMesajlarRaw) {
        final msg = Message.fromJson(eleman);
        String cozulmusMetin = '';

        // --- ÇÖZME (DECRYPTION) İŞLEMLERİ ---
        // Şifrelerken kullanılan anahtarların AYNISI burada da olmalı.
        switch (msg.yontem) {
          case 'Sezar':
            cozulmusMetin = _cryptoService.sezarCoz(msg.sifreliIcerik, 3);
            break;

          case 'Affine':
            cozulmusMetin = _cryptoService.affineCoz(msg.sifreliIcerik, 5, 8);
            break;

          case 'Playfair':
            const key = "SECRET";
            cozulmusMetin = _cryptoService.playfairCoz(msg.sifreliIcerik, key);
            break;

          case 'Substitution':
            const key = "QWERTYUIOPASDFGHJKLZXCVBNM";
            cozulmusMetin = _cryptoService.substitutionCoz(msg.sifreliIcerik, key);
            break;

          case 'Vigenere':
            const key = "ANAHTAR";
            cozulmusMetin = _cryptoService.vigenereCoz(msg.sifreliIcerik, key);
            break;

          case 'Rail Fence':
            int raySayisi = 3;
            cozulmusMetin = _cryptoService.railFenceCoz(msg.sifreliIcerik, raySayisi);
            break;

          case 'Route':
            int kolonSayisi = 4;
            cozulmusMetin = _cryptoService.routeCoz(msg.sifreliIcerik, kolonSayisi);
            break;

          case 'Columnar Transposition':
            const key = "GERMAN";
            cozulmusMetin = _cryptoService.columnarTranspositionCoz(msg.sifreliIcerik, key);
            break;

          case 'Polybius':
            cozulmusMetin = _cryptoService.polybiusCoz(msg.sifreliIcerik);
            break;

          case 'Hill':
            const key = "GYBNQKURP";
            cozulmusMetin = _cryptoService.hillCoz(msg.sifreliIcerik, key);
            break;

          case 'Vernam':
            const key = "RANDOMKEYGENERATEDFOREXAMPLE";
            cozulmusMetin = _cryptoService.vernamCoz(msg.sifreliIcerik, key);
            break;

          case 'AES (Lib)':
            cozulmusMetin = _cryptoService.aesLibCoz(msg.sifreliIcerik);
            break;

          case 'AES (Manual)':
            const key = "MYSECRETKEYMANUAL";
            cozulmusMetin = _cryptoService.aesManualCoz(msg.sifreliIcerik, key);
            break;

          case 'DES (Manual)':
            const key = "KEYDES88";
            cozulmusMetin = _cryptoService.desManualCoz(msg.sifreliIcerik, key);
            break;

          default:
          // Tanınmayan yöntemse olduğu gibi göster
            cozulmusMetin = msg.sifreliIcerik;
        }

        msg.cozulmusIcerik = cozulmusMetin;
        cozulmusMesajlar.add(msg);
      }



      setState(() {
        _mesajlar = cozulmusMesajlar.reversed.toList();
        _mesajlarYukleniyor = false;
      });
    } catch (e) {
      print("Hata oluştu: $e");
      setState(() => _mesajlarYukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currentUser} Paneli'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _mesajlariCek),
        ],
      ),
      body: Column(
        children: [



          // --- MESAJ LİSTESİ ALANI ---
          Expanded(
            child: _mesajlarYukleniyor
                ? const Center(child: CircularProgressIndicator())
                : _mesajlar.isEmpty
                ? const Center(child: Text("Henüz mesaj yok."))
                : ListView.builder(
              reverse: true,
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                final mesaj = _mesajlar[index];

                bool benimMesajim = mesaj.gonderen == widget.currentUser;

                return Align(
                  alignment: benimMesajim ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: benimMesajim ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: benimMesajim ? const Radius.circular(15) : Radius.zero,
                        bottomRight: benimMesajim ? Radius.zero : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gönderen Adı (Karşı tarafsa göster)
                        if (!benimMesajim)
                          Text(
                            mesaj.gonderen,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12),
                          ),

                        const SizedBox(height: 4),

                        Text(
                          mesaj.cozulmusIcerik,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "🔒 ${mesaj.sifreliIcerik} (${mesaj.yontem})",
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // --- MESAJ YAZMA ALANI  ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _seciliYontem,
                  underline: Container(), // Çizgiyi kaldırır
                  icon: const Icon(Icons.lock_outline, size: 20),
                  items: _sifrelemeYontemleri.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setState(() => _seciliYontem = v!),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: _mesajController,
                    decoration: InputDecoration(
                      hintText: "Mesaj yazın...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),

                const SizedBox(width: 8),


                _isLoading
                    ? const SizedBox(width: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                    : CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _mesajGonder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}