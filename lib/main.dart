import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TahminOyunu());
}

class TahminOyunu extends StatelessWidget {
  const TahminOyunu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tahmin Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  TextEditingController _controller = TextEditingController();
  late int _randomNumber;
  String _feedback = '';
  int _countdown = 40; // Sayaç 40 saniyeden başlıyor
  late Timer _timer;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    _generateRandomNumber();
  }

  void _generateRandomNumber() {
    final random = Random();
    _randomNumber = random.nextInt(100) + 1;
  }

  void _checkGuess(int guess) {
    if (!_timerStarted) {
      _startTimer();
      _timerStarted = true;
    }
    setState(() {
      if (guess == _randomNumber) {
        _feedback = 'Tebrikler! Doğru tahmin ettiniz.';
      } else if (guess < _randomNumber) {
        _feedback = 'Daha yüksek bir sayı girin.';
      } else {
        _feedback = 'Daha düşük bir sayı girin.';
      }
    });
  }

  void _handleSubmitted(String value) {
    int? guess = int.tryParse(value);
    if (guess != null) {
      _checkGuess(guess);
    }
    _controller.clear();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer.cancel();
        _generateRandomNumber();
        setState(() {
          _countdown = 40; // Yeni sayı üretildiğinde sayaç 40 saniyeye ayarlanıyor
          _feedback = '';
        });
        _startTimer(); // Yeni sayı üretildiğinde sayaç tekrar başlatılıyor
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahmin Et'),
        backgroundColor: Colors.indigo, // App Bar rengi
        elevation: 0, // Gölgelik kaldırma
      ),
      backgroundColor: Colors.indigo[400], // Arka plan rengi
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '0 ile 100 arasında bir sayı tahmin edin.',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Container'ın arka plan rengi
                borderRadius: BorderRadius.circular(10.0), // Container'ın köşe yarıçapı
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number, // Sadece sayı girişi
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))], // Yalnızca sayı girişine izin verir
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Sayıyı girin',
                  border: InputBorder.none, // Kenarlık yok
                ),
                onSubmitted: _handleSubmitted,
              ),
            ),


            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                int guess = int.tryParse(_controller.text) ?? 0;
                _checkGuess(guess);
                _controller.clear();
                if (_feedback == 'Tebrikler! Doğru tahmin ettiniz.') {
                  _generateRandomNumber();
                  _countdown = 40;
                }
              },
              child: const Text(
                'Tahmin Et',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                textStyle: const TextStyle(fontSize: 18.0),
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Butonun köşelerini yuvarlar
                  side: const BorderSide(color: Colors.white, width: 2), // Butonun kenarlık rengini ve kalınlığını belirler
                ),
              ),
            ),
            const SizedBox(height: 10.0), // Boşluk ekledik
            Text(
              _feedback,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: _feedback.contains('Tebrikler') ? Colors.green : _feedback.contains('yüksek') ? Colors.blue : Colors.red),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.red), // Timer iconu
                const SizedBox(width: 5),
                Text(
                  'Kalan Süre: $_countdown saniye',
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}