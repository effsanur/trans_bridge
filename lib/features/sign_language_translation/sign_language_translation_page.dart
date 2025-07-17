import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:trans_bridge/main.dart'; // Bu satır eklendi: global cameras değişkenine erişim için

// Kamerayı global olarak main.dart'ta tanımlanacak ve burada kullanılacak.
// Bu dosyada tekrar tanımlamaya gerek yok.

class SignLanguageTranslationPage extends StatefulWidget {
  const SignLanguageTranslationPage({super.key});

  @override
  State<SignLanguageTranslationPage> createState() => _SignLanguageTranslationPageState();
}

class _SignLanguageTranslationPageState extends State<SignLanguageTranslationPage> {
  bool _isSignLanguageMode = true; // İşaret Dili -> Ses modu (varsayılan)
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  Timer? _timer;
  String _detectedText = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Backend URL'i: Kendi Flask sunucunuzun IP adresini kullanmalısınız.
  // Eğer aynı bilgisayarda çalışıyorsa 127.0.0.1 (localhost) yeterlidir.
  // Ama mobil cihazda test ediyorsanız, bilgisayarınızın yerel ağ IP'si (örn. 192.168.1.111) olmalı.
  final String _backendUrl = 'http://192.168.1.111:5000/process_frame'; // Burayı KENDİ IP ADRESİNİZE göre güncelleyin!

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // 'cameras' global değişkenine erişim
    // main.dart'tan gelen 'cameras' değişkeninin boş olup olmadığını kontrol edin
    if (cameras.isEmpty) { // Artık cameras değişkenine erişebilmeli
      print('Kamera bulunamadı.');
      if (mounted) {
        setState(() {
          _detectedText = 'Kamera bulunamadı veya başlatılamadı.';
        });
      }
      return;
    }

    _cameraController = CameraController(
      cameras[0], // İlk kamerayı kullan
      ResolutionPreset.medium,
      enableAudio: false, // Sadece video akışı için ses kapalı
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return; // Widget hala ağaçtaysa devam et
      setState(() {
        _isCameraInitialized = true;
      });
      _startImageStreaming(); // Kamera başlatılınca akışı başlat
    } on CameraException catch (e) {
      print('Kamera başlatılamadı: $e');
      if (mounted) {
        setState(() {
          _detectedText = 'Kamera başlatılamadı: ${e.code}';
        });
      }
    } catch (e) {
      print('Genel kamera hatası: $e');
      if (mounted) {
        setState(() {
          _detectedText = 'Kamera hatası: $e';
        });
      }
    }
  }

  void _startImageStreaming() {
    _timer?.cancel(); // Önceki zamanlayıcıyı iptal et
    if (_isSignLanguageMode) {
      // İşaret Dili -> Ses modundaysa her 200 ms'de bir kare gönder
      _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        _sendFrameToBackend();
      });
    }
  }

  Future<void> _sendFrameToBackend() async {
    // Kamera hazır değilse veya zaten bir işlem varsa geri dön
    if (!_isCameraInitialized || _cameraController == null || !_cameraController!.value.isInitialized || _cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      // Kameradan bir kare al
      final XFile image = await _cameraController!.takePicture();
      final Uint8List imageBytes = await image.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Backend'e POST isteği gönder
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'image': base64Image}),
      );

      if (!mounted) return; // Widget hala ağaçtaysa devam et

      if (response.statusCode == 200) {
        // Başarılı yanıt durumunda
        final data = jsonDecode(response.body);
        setState(() {
          _detectedText = data['detected_text'] ?? 'Algılanan metin yok.'; // Algılanan metni güncelle
        });
        // Ses dosyasını oynat (eğer varsa ve doğru moddaysa)
        if (data['audio_base64'] != null && _isSignLanguageMode) {
          _playAudio(data['audio_base64']);
        }
      } else {
        // Hata kodu durumunda
        setState(() {
          _detectedText = 'API Hatası: ${response.statusCode} - ${response.body}';
        });
        print('API Hatası: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Ağ veya diğer hatalar durumunda
      if (!mounted) return;
      setState(() {
        _detectedText = 'Bağlantı hatası: ${e.toString()}';
      });
      print('Bağlantı hatası: $e');
    }
  }

  Future<void> _playAudio(String base64String) async {
    try {
      final Uint8List audioBytes = base64Decode(base64String);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      print('Ses oynatma hatası: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Zamanlayıcıyı iptal et
    _cameraController?.dispose(); // Kamerayı serbest bırak
    _audioPlayer.dispose(); // Ses oynatıcıyı serbest bırak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6E21B5), // Arka plan rengi
      appBar: AppBar(
        title: const Text('Bridge AI Transe', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6E21B5),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SES → İŞARET DİLİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    Switch(
                      value: _isSignLanguageMode,
                      onChanged: (val) {
                        setState(() {
                          _isSignLanguageMode = val;
                          if (_isSignLanguageMode) {
                            _startImageStreaming(); // Mod değişince akışı başlat
                          } else {
                            _timer?.cancel(); // Mod değişince akışı durdur
                          }
                        });
                      },
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                    const Text('İŞARET DİLİ → SES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.red),
                    SizedBox(width: 8),
                    Text('KAMERA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: _isCameraInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator(color: Color(0xFF6E21B5))),
                ),
                const SizedBox(height: 20),
                const Text('ALGILANAN METİN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(10),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_detectedText, style: const TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('ÇEVRİLEN MP3 DOSYASI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      iconSize: 50,
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        // Ses oynatma mantığı buraya eklenecek
                        // _playAudio(base64AudioData); // Eğer bir ses varsa oynat
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      iconSize: 50,
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        _audioPlayer.stop(); // Sesi durdur
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      iconSize: 50,
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () {
                        // Ses seviyesi kontrolü veya başka bir ses ayarı
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
