import 'dart:math';
import 'package:encrypt/encrypt.dart' as enc;
import 'dart:convert';

class CryptoService {

  // =========================================================
  // 1. SEZAR (CAESAR)
  // =========================================================
  String sezarSifrele(String metin, int anahtar) {
    return _sezar(metin, anahtar);
  }

  String sezarCoz(String metin, int anahtar) {
    return _sezar(metin, -anahtar);
  }

  String _sezar(String metin, int anahtar) {
    StringBuffer sonuc = StringBuffer();
    for (var c in metin.runes) {
      if (c >= 65 && c <= 90) { // A-Z
        sonuc.writeCharCode(((c - 65 + anahtar) % 26 + 26) % 26 + 65);
      } else if (c >= 97 && c <= 122) { // a-z
        sonuc.writeCharCode(((c - 97 + anahtar) % 26 + 26) % 26 + 97);
      } else {
        sonuc.writeCharCode(c);
      }
    }
    return sonuc.toString();
  }

  // =========================================================
  // 2. AFFINE
  // =========================================================
  String affineSifrele(String metin, int a, int b) {
    return _affine(metin, a, b, false);
  }

  String affineCoz(String metin, int a, int b) {
    return _affine(metin, a, b, true);
  }

  int _modInverse(int a, int m) {
    for (int x = 1; x < m; x++) {
      if ((a * x) % m == 1) return x;
    }
    return 1;
  }

  String _affine(String metin, int a, int b, bool decrypt) {
    StringBuffer sonuc = StringBuffer();
    int aInv = decrypt ? _modInverse(a, 26) : a;

    for (var c in metin.runes) {
      if (c >= 65 && c <= 90) {
        int x = c - 65;
        int kod = decrypt ? (aInv * (x - b)) % 26 : (a * x + b) % 26;
        sonuc.writeCharCode(((kod + 26) % 26) + 65);
      } else if (c >= 97 && c <= 122) {
        int x = c - 97;
        int kod = decrypt ? (aInv * (x - b)) % 26 : (a * x + b) % 26;
        sonuc.writeCharCode(((kod + 26) % 26) + 97);
      } else {
        sonuc.writeCharCode(c);
      }
    }
    return sonuc.toString();
  }

  // =========================================================
  // 3. PLAYFAIR
  // =========================================================
  List<List<String>> _generatePlayfairTable(String key) {
    key = key.toUpperCase().replaceAll("J", "I").replaceAll(RegExp(r'[^A-Z]'), '');
    List<String> alphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ".split("");
    List<String> unique = [];

    for (var char in key.split("") + alphabet) {
      if (!unique.contains(char)) unique.add(char);
    }
    return List.generate(5, (i) => unique.sublist(i * 5, i * 5 + 5));
  }

  String playfairSifrele(String text, String key) {
    return _playfair(text, key, false);
  }

  String playfairCoz(String text, String key) {
    return _playfair(text, key, true);
  }

  String _playfair(String text, String key, bool decrypt) {
    String cleanText = text.toUpperCase().replaceAll("J", "I").replaceAll(RegExp(r'[^A-Z]'), '');
    List<List<String>> table = _generatePlayfairTable(key);

    if (!decrypt) {
      String processed = "";
      for (int i = 0; i < cleanText.length; i++) {
        processed += cleanText[i];
        if (i + 1 < cleanText.length && cleanText[i] == cleanText[i + 1]) {
          processed += "X";
        }
      }
      if (processed.length % 2 == 1) processed += "X";
      cleanText = processed;
    }

    StringBuffer sonuc = StringBuffer();
    for (int i = 0; i < cleanText.length; i += 2) {
      String a = cleanText[i];
      String b = cleanText[i + 1];
      int ax = 0, ay = 0, bx = 0, by = 0;

      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          if (table[r][c] == a) { ax = r; ay = c; }
          if (table[r][c] == b) { bx = r; by = c; }
        }
      }

      if (ax == bx) { // Aynı satır
        sonuc.write(table[ax][(ay + (decrypt ? -1 : 1) + 5) % 5]);
        sonuc.write(table[bx][(by + (decrypt ? -1 : 1) + 5) % 5]);
      } else if (ay == by) { // Aynı sütun
        sonuc.write(table[(ax + (decrypt ? -1 : 1) + 5) % 5][ay]);
        sonuc.write(table[(bx + (decrypt ? -1 : 1) + 5) % 5][by]);
      } else { // Dikdörtgen
        sonuc.write(table[ax][by]);
        sonuc.write(table[bx][ay]);
      }
    }
    return sonuc.toString();
  }

  // =========================================================
  // 4. SUBSTITUTION
  // =========================================================
  String substitutionSifrele(String metin, String keyAlphabet) {
    return _substitution(metin, keyAlphabet, false);
  }

  String substitutionCoz(String metin, String keyAlphabet) {
    return _substitution(metin, keyAlphabet, true);
  }

  String _substitution(String metin, String key, bool decrypt) {
    String normal = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    key = key.toUpperCase();
    Map<String, String> map = {};

    for (int i = 0; i < 26; i++) {
      if (decrypt) {
        map[key[i]] = normal[i];
      } else {
        map[normal[i]] = key[i];
      }
    }

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < metin.length; i++) {
      String char = metin[i].toUpperCase();
      if (map.containsKey(char)) {
        sb.write(map[char]);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  // =========================================================
  // 5. VIGENERE
  // =========================================================
  String vigenereSifrele(String metin, String anahtar) {
    return _vigenere(metin, anahtar, false);
  }

  String vigenereCoz(String metin, String anahtar) {
    return _vigenere(metin, anahtar, true);
  }

  String _vigenere(String metin, String key, bool decrypt) {
    StringBuffer sb = StringBuffer();
    key = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (key.isEmpty) return metin;

    int keyIndex = 0;
    for (int i = 0; i < metin.length; i++) {
      int charCode = metin.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) { // A-Z
        int shift = key.codeUnitAt(keyIndex % key.length) - 65;
        if (decrypt) shift = -shift;
        sb.writeCharCode(((charCode - 65 + shift + 26) % 26) + 65);
        keyIndex++;
      } else if (charCode >= 97 && charCode <= 122) { // a-z
        int shift = key.codeUnitAt(keyIndex % key.length) - 65;
        if (decrypt) shift = -shift;
        sb.writeCharCode(((charCode - 97 + shift + 26) % 26) + 97);
        keyIndex++;
      } else {
        sb.write(metin[i]);
      }
    }
    return sb.toString();
  }

  // =========================================================
  // 6. RAIL FENCE
  // =========================================================
  String railFenceSifrele(String text, int numRails) {
    if (numRails <= 1) return text;
    List<StringBuffer> rails = List.generate(numRails, (index) => StringBuffer());
    int rail = 0;
    bool directionDown = false;

    for (int i = 0; i < text.length; i++) {
      rails[rail].write(text[i]);
      if (rail == 0 || rail == numRails - 1) directionDown = !directionDown;
      rail += directionDown ? 1 : -1;
    }
    return rails.map((sb) => sb.toString()).join();
  }

  String railFenceCoz(String text, int numRails) {
    if (numRails <= 1) return text;
    int len = text.length;
    List<List<String>> grid = List.generate(numRails, (_) => List.filled(len, '\n'));

    // Zikzak yolunu işaretle
    int rail = 0;
    bool directionDown = false;
    for (int i = 0; i < len; i++) {
      grid[rail][i] = '*';
      if (rail == 0 || rail == numRails - 1) directionDown = !directionDown;
      rail += directionDown ? 1 : -1;
    }

    // Grid'i doldur
    int index = 0;
    for (int r = 0; r < numRails; r++) {
      for (int c = 0; c < len; c++) {
        if (grid[r][c] == '*' && index < len) {
          grid[r][c] = text[index++];
        }
      }
    }

    // Zikzak okuma
    StringBuffer sb = StringBuffer();
    rail = 0;
    directionDown = false;
    for (int i = 0; i < len; i++) {
      sb.write(grid[rail][i]);
      if (rail == 0 || rail == numRails - 1) directionDown = !directionDown;
      rail += directionDown ? 1 : -1;
    }
    return sb.toString();
  }

  // =========================================================
  // 7. ROUTE CIPHER
  // =========================================================
  String routeSifrele(String text, int cols) {
    text = text.replaceAll(' ', '');
    int rows = (text.length / cols).ceil();
    List<String> grid = List.filled(rows * cols, 'X');

    for(int i=0; i<text.length; i++) grid[i] = text[i];

    StringBuffer sb = StringBuffer();
    // Sütun sütun oku
    for(int c=0; c<cols; c++){
      for(int r=0; r<rows; r++){
        sb.write(grid[r*cols + c]);
      }
    }
    return sb.toString();
  }

  String routeCoz(String text, int cols) {
    int rows = (text.length / cols).ceil();
    List<String> grid = List.filled(rows * cols, ' ');

    int index = 0;
    // Sütun sütun doldur
    for(int c=0; c<cols; c++){
      for(int r=0; r<rows; r++){
        if(index < text.length) {
          grid[r*cols + c] = text[index++];
        }
      }
    }
    // Satır satır oku
    return grid.join('').replaceAll('X', ''); // Padding X'leri temizle
  }

  // =========================================================
  // 8. COLUMNAR TRANSPOSITION
  // =========================================================
  String columnarTranspositionSifrele(String text, String key) {
    key = key.toUpperCase();
    int colCount = key.length;
    int rowCount = (text.length / colCount).ceil();
    // Padding
    text = text.padRight(rowCount * colCount, '_');

    // Anahtar sıralaması
    List<int> order = List.generate(colCount, (i) => i);
    order.sort((a, b) => key.codeUnitAt(a).compareTo(key.codeUnitAt(b)));

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < colCount; i++) {
      int currentKeyCol = order[i];
      for (int r = 0; r < rowCount; r++) {
        sb.write(text[r * colCount + currentKeyCol]);
      }
    }
    return sb.toString();
  }

  String columnarTranspositionCoz(String text, String key) {
    key = key.toUpperCase();
    int colCount = key.length;
    int rowCount = text.length ~/ colCount;

    List<int> order = List.generate(colCount, (i) => i);
    order.sort((a, b) => key.codeUnitAt(a).compareTo(key.codeUnitAt(b)));

    List<List<String>> grid = List.generate(rowCount, (_) => List.filled(colCount, ''));
    int index = 0;

    for (int i = 0; i < colCount; i++) {
      int currentKeyCol = order[i];
      for (int r = 0; r < rowCount; r++) {
        if(index < text.length) {
          grid[r][currentKeyCol] = text[index++];
        }
      }
    }

    StringBuffer sb = StringBuffer();
    for(var row in grid) {
      sb.write(row.join());
    }
    return sb.toString().replaceAll('_', '');
  }

  // =========================================================
  // 9. POLYBIUS SQUARE
  // =========================================================
  String polybiusSifrele(String text) {
    text = text.toUpperCase().replaceAll("J", "I").replaceAll(RegExp(r'[^A-Z]'), '');
    String grid = "ABCDEFGHIKLMNOPQRSTUVWXYZ"; // 5x5
    StringBuffer sb = StringBuffer();

    for(int i=0; i<text.length; i++) {
      int index = grid.indexOf(text[i]);
      if(index != -1) {
        int row = (index ~/ 5) + 1;
        int col = (index % 5) + 1;
        sb.write("$row$col ");
      }
    }
    return sb.toString().trim();
  }

  String polybiusCoz(String text) {
    text = text.replaceAll(' ', '');
    String grid = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    StringBuffer sb = StringBuffer();

    for(int i=0; i<text.length; i+=2) {
      if(i+1 < text.length) {
        int row = int.parse(text[i]) - 1;
        int col = int.parse(text[i+1]) - 1;
        if(row >= 0 && row < 5 && col >=0 && col < 5) {
          sb.write(grid[row*5 + col]);
        }
      }
    }
    return sb.toString();
  }


  // =========================================================
  // 11. HILL CIPHER (2x2 Matrix Örneği)
  // =========================================================
  String hillSifrele(String text, String keyMatrixString) {
    List<int> vector = [];
    text = text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (text.length % 2 != 0) text += "X"; // Çiftle


    int k00 = 3, k01 = 3, k10 = 2, k11 = 5;

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < text.length; i += 2) {
      int p1 = text.codeUnitAt(i) - 65;
      int p2 = text.codeUnitAt(i+1) - 65;

      int c1 = (k00 * p1 + k01 * p2) % 26;
      int c2 = (k10 * p1 + k11 * p2) % 26;

      sb.writeCharCode(c1 + 65);
      sb.writeCharCode(c2 + 65);
    }
    return sb.toString();
  }

  String hillCoz(String text, String keyUnused) {

    int i00 = 15, i01 = 17, i10 = 20, i11 = 9;

    StringBuffer sb = StringBuffer();
    for (int i = 0; i < text.length; i += 2) {
      int c1 = text.codeUnitAt(i) - 65;
      int c2 = text.codeUnitAt(i+1) - 65;

      int p1 = (i00 * c1 + i01 * c2) % 26;
      int p2 = (i10 * c1 + i11 * c2) % 26;

      sb.writeCharCode(p1 + 65);
      sb.writeCharCode(p2 + 65);
    }
    return sb.toString();
  }

  // =========================================================
  // 12. VERNAM (ONE-TIME PAD)
  // =========================================================
  String vernamSifrele(String text, String key) {
    return _vernam(text, key, false);
  }

  String vernamCoz(String text, String key) {
    return _vernam(text, key, true);
  }

  String _vernam(String text, String key, bool decrypt) {
    text = text.toUpperCase();
    key = key.toUpperCase();
    StringBuffer sb = StringBuffer();

    for(int i=0; i<text.length; i++) {
      int tVal = text.codeUnitAt(i) - 65;
      int kVal = key.codeUnitAt(i % key.length) - 65;

      int res;
      if(!decrypt) {
        res = (tVal + kVal) % 26;
      } else {
        res = (tVal - kVal + 26) % 26;
      }

      if(tVal < 0 || tVal > 25) {
        sb.write(text[i]);
      } else {
        sb.writeCharCode(res + 65);
      }
    }
    return sb.toString();
  }

  // =========================================================
  // 13. AES (KÜTÜPHANELİ)
  // =========================================================
  final _aesKey = enc.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars
  final _aesIV = enc.IV.fromLength(16);

  String aesLibSifrele(String text) {
    final encrypter = enc.Encrypter(enc.AES(_aesKey));
    final encrypted = encrypter.encrypt(text, iv: _aesIV);
    return encrypted.base64;
  }

  String aesLibCoz(String text) {
    final encrypter = enc.Encrypter(enc.AES(_aesKey));
    return encrypter.decrypt(enc.Encrypted.fromBase64(text), iv: _aesIV);
  }


  // =========================================================
  // 15. AES (KÜTÜPHANESİZ / MANUEL - EĞİTİM AMAÇLI SİMÜLASYON)
  // Gerçek AES binlerce satır S-Box tablosu gerektirir.
  // Bu fonksiyon AES mantığını (XOR + Key Expansion) simüle eder.
  // =========================================================
  String aesManualSifrele(String text, String key) {
    // Basit bir XOR şifreleme ve Base64 dönüşümü (Mantığı göstermek için)
    List<int> bytes = utf8.encode(text);
    List<int> keyBytes = utf8.encode(key);
    List<int> result = [];

    for (int i = 0; i < bytes.length; i++) {
      // XOR işlemi ve basit bir bit kaydırma
      result.add((bytes[i] ^ keyBytes[i % keyBytes.length]) + 1);
    }
    return base64.encode(result);
  }

  String aesManualCoz(String text, String key) {
    try {
      List<int> bytes = base64.decode(text);
      List<int> keyBytes = utf8.encode(key);
      List<int> result = [];

      for (int i = 0; i < bytes.length; i++) {
        // Geri işlem
        result.add((bytes[i] - 1) ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(result);
    } catch (e) {
      return text;
    }
  }

  // =========================================================
  // 16. DES (KÜTÜPHANESİZ / MANUEL - EĞİTİM AMAÇLI SİMÜLASYON)
  // =========================================================
  String desManualSifrele(String text, String key) {
    // DES benzeri blok mantığı simülasyonu
    List<int> bytes = utf8.encode(text);
    List<int> keyBytes = utf8.encode(key);
    List<int> result = [];

    // Her byte'ı anahtarla manipüle et
    for (int i = 0; i < bytes.length; i++) {
      int processed = (bytes[i] + keyBytes[i % keyBytes.length]) % 256;
      result.add(processed);
    }
    return base64.encode(result);
  }

  String desManualCoz(String text, String key) {
    try {
      List<int> bytes = base64.decode(text);
      List<int> keyBytes = utf8.encode(key);
      List<int> result = [];

      for (int i = 0; i < bytes.length; i++) {
        int processed = (bytes[i] - keyBytes[i % keyBytes.length]) % 256;
        if (processed < 0) processed += 256;
        result.add(processed);
      }
      return utf8.decode(result);
    } catch (e) {
      return text;
    }
  }
}


