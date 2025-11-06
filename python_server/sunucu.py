from flask import Flask, request, jsonify
from datetime import datetime

import itertools

app = Flask(__name__)


mesaj_kutusu = []
mesaj_id_sayaci = itertools.count()

@app.route('/mesaj_gonder', methods=['POST'])
def mesaj_gonder():
    if not request.is_json:
        return jsonify({"hata": "İstek JSON formatında olmalıdır."}), 400

    gelen_veri = request.get_json()

    zorunlu_alanlar = ['gonderen', 'sifreli_icerik', 'yontem']
    if not all(alan in gelen_veri for alan in zorunlu_alanlar):
        return jsonify({"hata": "Eksik bilgi gönderildi. 'gonderen', 'sifreli_icerik', 'yontem' zorunludur."}), 400

    yeni_mesaj = {
        'id': next(mesaj_id_sayaci),
        'gonderen': gelen_veri['gonderen'],
        'sifreli_icerik': gelen_veri['sifreli_icerik'],
        'yontem': gelen_veri['yontem'],
        'timestamp': datetime.now().isoformat()
    }

    mesaj_kutusu.append(yeni_mesaj)

    return jsonify({"durum": "basarili", "mesaj": "Mesaj başarıyla eklendi.", "data": yeni_mesaj}), 201


@app.route('/mesajlari_al', methods=['GET'])
def mesajlari_al():
    return jsonify(sorted(mesaj_kutusu, key=lambda m: m['id'], reverse=True))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
