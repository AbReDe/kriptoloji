class CryptoService {
  // ---------------------------------------------------------
  // SEZAR Şifreleme / Deşifreleme
  // ---------------------------------------------------------
  String sezarSifrele(String metin, int anahtar) {
    return _sezar(metin, anahtar);
  }

  String sezarCoz(String metin, int anahtar) {
    return _sezar(metin, -anahtar);
  }

  String _sezar(String metin, int anahtar) {
    StringBuffer sonuc = StringBuffer();
    for (var c in metin.runes) {
      if (c >= 65 && c <= 90) {
        sonuc.writeCharCode(((c - 65 + anahtar) % 26 + 26) % 26 + 65);
      } else if (c >= 97 && c <= 122) {
        sonuc.writeCharCode(((c - 97 + anahtar) % 26 + 26) % 26 + 97);
      } else {
        sonuc.writeCharCode(c);
      }
    }
    return sonuc.toString();
  }

  // ---------------------------------------------------------
  // AFFINE Şifreleme / Deşifreleme
  // ---------------------------------------------------------
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




  // ---------------------------------------------------------
  // PLAYFAIR Şifreleme / Deşifreleme
  // ---------------------------------------------------------
  List<List<String>> _generatePlayfairTable(String key) {
    key = key.toUpperCase().replaceAll("J", "I");
    List<String> alphabet =
    "ABCDEFGHIKLMNOPQRSTUVWXYZ".split(""); // J yok

    List<String> unique = [];
    for (var char in key.split("") + alphabet) {
      if (!unique.contains(char) && alphabet.contains(char)) {
        unique.add(char);
      }
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
    text = text.toUpperCase().replaceAll("J", "I").replaceAll(" ", "");
    List<List<String>> table = _generatePlayfairTable(key);

    if (!decrypt) {
      for (int i = 0; i < text.length - 1; i += 2) {
        if (text[i] == text[i + 1]) {
          text = text.substring(0, i + 1) + "X" + text.substring(i + 1);
        }
      }
      if (text.length % 2 == 1) text += "X";
    }

    StringBuffer sonuc = StringBuffer();

    for (int i = 0; i < text.length; i += 2) {
      String a = text[i];
      String b = text[i + 1];

      int ax = 0, ay = 0, bx = 0, by = 0;

      for (int x = 0; x < 5; x++) {
        for (int y = 0; y < 5; y++) {
          if (table[x][y] == a) {
            ax = x;
            ay = y;
          }
          if (table[x][y] == b) {
            bx = x;
            by = y;
          }
        }
      }

      if (ax == bx) {
        sonuc.write(table[ax][(ay + (decrypt ? -1 : 1) + 5) % 5]);
        sonuc.write(table[bx][(by + (decrypt ? -1 : 1) + 5) % 5]);
      } else if (ay == by) {
        sonuc.write(table[(ax + (decrypt ? -1 : 1) + 5) % 5][ay]);
        sonuc.write(table[(bx + (decrypt ? -1 : 1) + 5) % 5][by]);
      } else {
        sonuc.write(table[ax][by]);
        sonuc.write(table[bx][ay]);
      }
    }

    return sonuc.toString();
  }
}
