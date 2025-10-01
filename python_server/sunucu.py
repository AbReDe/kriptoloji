
from flask import Flask, request, jsonify
from datetime import datetime
import itertools


app = Flask(__name__)

mesaj_kutusu = []
mesaj_id_sayaci = itertools.count()


@app.route('/mesaj_gonder', methods=['POST'])
def mesaj_gonder():
    gelen_veri = request.get_json()

    if not gelen_veri or 'gonderen' not in gelen_veri or 'sifreli_icerik' not in gelen_veri or 'yontem' not in gelen_veri:
        return jsonify({"hata": "Eksik bilgi gönderildi. 'gonderen', 'sifreli_icerik' ve 'yontem' alanları zorunludur."}), 400

    
    gonderen = gelen_veri['gonderen']
    sifreli_icerik = gelen_veri['sifreli_icerik']
    yontem = gelen_veri['yontem']

   
    yeni_mesaj = {
        'id': next(mesaj_id_sayaci),  
        'gonderen': gonderen,
        'sifreli_icerik': sifreli_icerik,
        'yontem': yontem,
        'timestamp': datetime.now().isoformat()  
    }

    mesaj_kutusu.append(yeni_mesaj)

   
    print(f"Yeni mesaj alındı ve eklendi: {yeni_mesaj}")

   
    return jsonify({"durum": "basarili", "mesaj": "Mesaj başarıyla sunucuya eklendi."}), 201



@app.route('/mesajlari_al', methods=['GET'])
def mesajlari_al():
    return jsonify(sorted(mesaj_kutusu, key=lambda m: m['id'], reverse=True))



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
