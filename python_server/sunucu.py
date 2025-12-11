import json
import os
import itertools
from datetime import datetime
from flask import Flask, request, jsonify

app = Flask(__name__)


VERITABANI_DOSYASI = 'mesajlar.json'



def verileri_yukle():
    """JSON dosyasından mesajları okur."""
    if not os.path.exists(VERITABANI_DOSYASI):
        return []
    try:
        with open(VERITABANI_DOSYASI, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Veri yükleme hatası: {e}")
        return []

def verileri_kaydet(mesajlar):
    """Mesajları JSON dosyasına yazar."""
    try:
        with open(VERITABANI_DOSYASI, 'w', encoding='utf-8') as f:
            json.dump(mesajlar, f, ensure_ascii=False, indent=4)
    except Exception as e:
        print(f"Veri kaydetme hatası: {e}")


mesaj_kutusu = verileri_yukle()


baslangic_id = 1
if mesaj_kutusu:
    baslangic_id = max(m.get('id', 0) for m in mesaj_kutusu) + 1

mesaj_id_sayaci = itertools.count(baslangic_id)


# --- API ENDPOINTLERİ ---

@app.route('/mesaj_gonder', methods=['POST'])
def mesaj_gonder():
    if not request.is_json:
        return jsonify({"hata": "İstek JSON formatında olmalıdır."}), 400

    gelen_veri = request.get_json()
    zorunlu_alanlar = ['gonderen', 'sifreli_icerik', 'yontem']
    if not all(alan in gelen_veri for alan in zorunlu_alanlar):
        return jsonify({"hata": "Eksik bilgi: 'gonderen', 'sifreli_icerik', 'yontem' gereklidir."}), 400

    tarih_saat = datetime.now().strftime("%d-%m-%Y %H:%M")

    yeni_mesaj = {
        'id': next(mesaj_id_sayaci),
        'gonderen': gelen_veri['gonderen'],
        'sifreli_icerik': gelen_veri['sifreli_icerik'],
        'yontem': gelen_veri['yontem'],   
        'timestamp': tarih_saat
    }

  
    mesaj_kutusu.append(yeni_mesaj)
    verileri_kaydet(mesaj_kutusu)

    print(f"📨 Yeni Mesaj: {yeni_mesaj['gonderen']} -> {yeni_mesaj['yontem']} ile şifreledi.")
    
    return jsonify({
        "durum": "basarili", 
        "mesaj": "Mesaj veritabanına kaydedildi.", 
        "data": yeni_mesaj
    }), 201


@app.route('/mesajlari_al', methods=['GET'])
def mesajlari_al():
    guncel_mesajlar = verileri_yukle()
    return jsonify(guncel_mesajlar)


@app.route('/sifirla', methods=['DELETE'])
def veritabanini_sifirla():
    """İstersen tüm mesajları silmek için kullanabileceğin ekstra bir fonksiyon"""
    global mesaj_kutusu
    mesaj_kutusu = []
    if os.path.exists(VERITABANI_DOSYASI):
        os.remove(VERITABANI_DOSYASI)
    return jsonify({"durum": "Veritabanı temizlendi"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)