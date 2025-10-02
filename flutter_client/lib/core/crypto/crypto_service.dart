class CryptoService {
  // Basit bir Sezar Şifrelemesi
  String sezarSifrele(String metin, int anahtar) {
    StringBuffer sifreli = StringBuffer();
    for (int i = 0; i < metin.length; i++) {
      int charCode = metin.codeUnitAt(i);

      // Sadece basit ASCII harflerini kaydırıyoruz, diğer karakterler aynı kalıyor
      if (charCode >= 65 && charCode <= 90) { // Büyük harfler
        sifreli.writeCharCode(((charCode - 65 + anahtar) % 26) + 65);
      } else if (charCode >= 97 && charCode <= 122) { // Küçük harfler
        sifreli.writeCharCode(((charCode - 97 + anahtar) % 26) + 97);
      } else {
        sifreli.writeCharCode(charCode); // Diğer karakterler
      }
    }
    return sifreli.toString();
  }


}