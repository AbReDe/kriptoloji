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

  // ================== MESAJ GÖNDER ==================
  void _mesajGonder() async {
    if (_mesajController.text.isEmpty) return;
    setState(() => _isLoading = true);

    String duz = _mesajController.text;
    String sifreli = '';

    switch (_seciliYontem) {
      case 'Sezar':
        sifreli = _cryptoService.sezarSifrele(duz, 3);
        break;
      case 'Affine':
        sifreli = _cryptoService.affineSifrele(duz, 5, 8);
        break;
      case 'Playfair':
        sifreli = _cryptoService.playfairSifrele(duz, "SECRET");
        break;
      case 'Substitution':
        sifreli = _cryptoService.substitutionSifrele(
            duz, "QWERTYUIOPASDFGHJKLZXCVBNM");
        break;
      case 'Vigenere':
        sifreli = _cryptoService.vigenereSifrele(duz, "ANAHTAR");
        break;
      case 'Rail Fence':
        sifreli = _cryptoService.railFenceSifrele(duz, 3);
        break;
      case 'Route':
        sifreli = _cryptoService.routeSifrele(duz, 4);
        break;
      case 'Columnar Transposition':
        sifreli = _cryptoService.columnarTranspositionSifrele(duz, "GERMAN");
        break;
      case 'Polybius':
        sifreli = _cryptoService.polybiusSifrele(duz);
        break;
      case 'Hill':
        sifreli = _cryptoService.hillSifrele(duz, "GYBNQKURP");
        break;
      case 'Vernam':
        sifreli = _cryptoService.vernamSifrele(
            duz, "RANDOMKEYGENERATEDFOREXAMPLE");
        break;
      case 'AES (Lib)':
        sifreli = _cryptoService.aesLibSifrele(duz);
        break;
      case 'AES (Manual)':
        sifreli = _cryptoService.aesManualSifrele(duz, "MYSECRETKEYMANUAL");
        break;
      case 'DES (Manual)':
        sifreli = _cryptoService.desManualSifrele(duz, "KEYDES88");
        break;
      default:
        sifreli = duz;
    }

    await _apiService.MesajGonder(
      gonderen: widget.currentUser,
      sifreliIcerik: sifreli,
      yontem: _seciliYontem,
    );

    _mesajController.clear();
    setState(() => _isLoading = false);
    _mesajlariCek();
  }

  // ================== MESAJ ÇEK ==================
  Future<void> _mesajlariCek() async {
    setState(() => _mesajlarYukleniyor = true);
    final raw = await _apiService.mesajlariAl();
    final List<Message> list = [];

    for (var e in raw) {
      final msg = Message.fromJson(e);
      String coz = '';

      switch (msg.yontem) {
        case 'Sezar':
          coz = _cryptoService.sezarCoz(msg.sifreliIcerik, 3);
          break;
        case 'Affine':
          coz = _cryptoService.affineCoz(msg.sifreliIcerik, 5, 8);
          break;
        case 'Playfair':
          coz = _cryptoService.playfairCoz(msg.sifreliIcerik, "SECRET");
          break;
        case 'Substitution':
          coz = _cryptoService.substitutionCoz(
              msg.sifreliIcerik, "QWERTYUIOPASDFGHJKLZXCVBNM");
          break;
        case 'Vigenere':
          coz = _cryptoService.vigenereCoz(msg.sifreliIcerik, "ANAHTAR");
          break;
        case 'Rail Fence':
          coz = _cryptoService.railFenceCoz(msg.sifreliIcerik, 3);
          break;
        case 'Route':
          coz = _cryptoService.routeCoz(msg.sifreliIcerik, 4);
          break;
        case 'Columnar Transposition':
          coz = _cryptoService.columnarTranspositionCoz(msg.sifreliIcerik, "GERMAN");
          break;
        case 'Polybius':
          coz = _cryptoService.polybiusCoz(msg.sifreliIcerik);
          break;
        case 'Hill':
          coz = _cryptoService.hillCoz(msg.sifreliIcerik, "GYBNQKURP");
          break;
        case 'Vernam':
          coz = _cryptoService.vernamCoz(
              msg.sifreliIcerik, "RANDOMKEYGENERATEDFOREXAMPLE");
          break;
        case 'AES (Lib)':
          coz = _cryptoService.aesLibCoz(msg.sifreliIcerik);
          break;
        case 'AES (Manual)':
          coz = _cryptoService.aesManualCoz(msg.sifreliIcerik, "MYSECRETKEYMANUAL");
          break;
        case 'DES (Manual)':
          coz = _cryptoService.desManualCoz(msg.sifreliIcerik, "KEYDES88");
          break;
        default:
          coz = msg.sifreliIcerik;
      }

      msg.cozulmusIcerik = coz;
      list.add(msg);
    }

    setState(() {
      _mesajlar = list.reversed.toList();
      _mesajlarYukleniyor = false;
    });
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF3F3D56),
        title: const Text(
          "Secure Chat",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _mesajlarYukleniyor
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                final m = _mesajlar[index];
                final benim = m.gonderen == widget.currentUser;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Align(
                    alignment: benim ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: benim ? const Color(0xFF5C6BC0) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!benim)
                            Text(
                              m.gonderen,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F3D56),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            m.cozulmusIcerik,
                            style: TextStyle(
                              fontSize: 16,
                              color: benim ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "🔐 ${m.yontem}",
                            style: TextStyle(
                              fontSize: 11,
                              color: benim
                                  ? Colors.white70
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _seciliYontem,
            underline: const SizedBox(),
            items: _sifrelemeYontemleri
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 12)),
            ))
                .toList(),
            onChanged: (v) => setState(() => _seciliYontem = v!),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _mesajController,
              decoration: InputDecoration(
                hintText: "Mesajınızı yazın...",
                filled: true,
                fillColor: const Color(0xFFF0F1F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : CircleAvatar(
            backgroundColor: const Color(0xFF3F3D56),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _mesajGonder,
            ),
          ),
        ],
      ),
    );
  }
}
