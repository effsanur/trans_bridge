from flask import Flask, request, jsonify
import cv2
import numpy as np
import base64
import tempfile
import os
from ultralytics import YOLO
from gtts import gTTS
from flask_cors import CORS
import time
import threading

app = Flask(__name__)
CORS(app)

model_path = "best.pt"

try:
    model = YOLO(model_path)
    print(f"YOLO modeli başarıyla yüklendi: {model_path}")
except Exception as e:
    print(f"HATA: YOLO modeli yüklenirken hata oluştu: {e}")
    model = None

# Kelimeleri biriktirmek için global liste ve zaman takibi
detected_words = []
last_detect_time = 0
lock = threading.Lock()  # Çoklu istek için güvenlik

def form_sentence(words):
    words = [w.lower() for w in words]

    if 'dur' in words:
        return "Lütfen dur."

    subjects = {'anne', 'baba', 'kardeş', 'arkadaş'}
    verbs = {'içmek', 'özür-dileme', 'yemek', 'dur'}

    subject_word = None
    verb_word = None

    for w in words:
        if w in subjects:
            subject_word = w
        if w in verbs:
            verb_word = w

    if subject_word and verb_word:
        if verb_word == 'içmek':
            verb_word = 'içiyor'
        elif verb_word == 'özür-dileme':
            verb_word = 'özür diliyor'
        elif verb_word == 'yemek':
            verb_word = 'yiyor'

        return f"{subject_word.capitalize()} {verb_word}."

    if 'nerede' in words:
        for w in words:
            if w in {'tuvalet', 'ev', 'telefon'}:
                return f"{w.capitalize()} nerede?"

    if 'nasıl' in words:
        for w in words:
            if w in {'ev', 'yemek', 'kötü', 'iyi'}:
                return f"{w.capitalize()} nasıl?"

    short_phrases = {'evet', 'hayır', 'tamam', 'teşekkürler'}
    for w in words:
        if w in short_phrases:
            return w.capitalize()

    return " ".join(words).capitalize()

def speak_text_to_base64_mp3(text):
    if not text:
        return None

    try:
        tts = gTTS(text=text, lang='tr')
        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as fp:
            temp_mp3_path = fp.name
        tts.save(temp_mp3_path)

        with open(temp_mp3_path, "rb") as f:
            mp3_bytes = f.read()
        encoded_mp3 = base64.b64encode(mp3_bytes).decode('utf-8')

        os.unlink(temp_mp3_path)
        return encoded_mp3
    except Exception as e:
        print(f"HATA: Ses oluşturulurken hata: {e}")
        return None

@app.route('/process_frame', methods=['POST'])
def process_frame():
    global detected_words, last_detect_time

    if model is None:
        return jsonify({"error": "Model yüklenemedi."}), 500

    data = request.json
    if not data or 'image' not in data:
        return jsonify({"error": "Resim verisi eksik."}), 400

    try:
        image_data = base64.b64decode(data['image'])
        nparr = np.frombuffer(image_data, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({"error": "Geçersiz resim verisi."}), 400

        results = model(img)[0]
        boxes = results.boxes
        names = model.names


        detected_label = ""
        if boxes and len(boxes) > 0:
            best_box_idx = boxes.conf.argmax()
            cls_id = int(boxes[best_box_idx].cls.cpu().numpy())
            detected_label = names[cls_id].lower()

        response_sentence = ""
        response_audio = None

        with lock:
            now = time.time()
            if detected_label:
                # Aynı kelime üst üste tekrar edilirse ekleme yapma
                if len(detected_words) == 0 or detected_label != detected_words[-1]:
                    detected_words.append(detected_label)
                last_detect_time = now

            # Eğer 4 saniyeden uzun süre yeni kelime yoksa cümle oluştur ve temizle
            if detected_words and (now - last_detect_time) > 4:
                response_sentence = form_sentence(detected_words)
                response_audio = speak_text_to_base64_mp3(response_sentence)
                detected_words = []

        return jsonify({
            "detected_text": response_sentence if response_sentence else detected_label,
            "audio_base64": response_audio
        })

    except Exception as e:
        print(f"Sunucu hatası: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
