// Import package yang dibutuhkan {async: Timer, math: Random, fl_chart: Chart}
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Fungsi utama untuk menampilkan Widget utama
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScatterChartSample2(),
  ));
}

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScatterChartSample2State createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456); // Warna lingkaran pada chart
  List<(double, double, double)> data = []; // List untuk menyimpan data titik (Posisi dan Ukuran)
  // Inisialisasi timer untuk display timer pada bagian bawah
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data setiap detik
    startFetchingData();
    _startTimer();
  }

  // Menghentikan timer ketika widget di tutup
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi untuk mengambil data posisi x, y dari modul atau API
  void fetchData() {
    // Random data untuk mencoba dinamisasi pada data posisi x dan y
    var random = Random();
    double x = random.nextDouble() * 10; // Menhasilkan nilai x lalu di-kali dengan 10
    double y = random.nextDouble() * 10; // Menhasilkan nilai y lalu di-kali dengan 10
    double size = 10.0; // Menetapkan ukuran sebagai 10

    // Memperbarui/set State dengan data baru
    setState(() {
      data.add((x, y, size)); // Menambahkan data baru ke dalam list
    });
  }

  // Fungsi fetching data setiap {periode} detik
  void startFetchingData() {
    const period = Duration(seconds: 5); // Menentukan periode fetch data yang akan di ganti pada list menjadi 5 detik
    Timer.periodic(period, (Timer t) {
      fetchData(); // Panggil fungsi fetchData setiap periode
    });
  }

  // Fungsi memulai perhitungan atau menampilkan timer
  // Menentukan periode hitungan/tampil timer setiap 10 detik
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _seconds += 10;
      });
    });
  }

  // Fungsi ini digunakan untuk menghasilkan label waktu berdasarkan nilai detik.
  // Misalnya, jika seconds = 30, maka fungsi ini akan menghasilkan label waktu:
  // ['20s', '30s']
  List<String> _generateTimeLabels(int seconds) {
    List<String> labels = [];
    
    // Mencari nilai awal yang merupakan kelipatan 10 terdekat dari seconds
    int start = seconds ~/ 10 * 10;

    // Menghasilkan label waktu dari start - 50 hingga start dengan interval 10
    for (int i = start - 50; i <= start; i += 10) {
      if (i <= 0) {
        labels.add('...'); // Jika i <= 0, tambahkan label '...'
      } else if (i < 60) {
        labels.add('${i}s'); // Jika i < 60, tambahkan label dengan format '${i}s'
      } else {
        int minutes = i ~/ 60; // Menghitung menit dari i dibagi 60
        int seconds = i % 60; // Menghitung detik dari i mod 60
        labels.add('${minutes}m${seconds.toString().padLeft(2, '0')}s'); // Format menit dan detik dengan 'm' dan 's'
      }
    }
    return labels.reversed.toList(); // Menampilkan label waktu yang dibalik urutannya
  }

  // Di dalam fungsi build ini, kita membuat daftar titik-titik pada chart (scatter chart)
// dari data yang kita miliki. Setiap data memiliki nilai x, y, dan ukuran (size).
// Kita menggunakan fungsi map untuk mengubah setiap elemen data menjadi objek ScatterSpotWithColor,
// yang berisi informasi titik (x, y) dan label x-nya dengan format dua angka di belakang koma.
  @override
  Widget build(BuildContext context) {
    List<ScatterSpotWithColor> spotsWithColors = data.map((e) {
      final (double x, double y, double size) = e;
      return ScatterSpotWithColor(
        spot: ScatterSpot(
          x,
          y,
          dotPainter: FlDotCirclePainter(
            color: circleColor,
            radius: size,
          ),
        ),
        color: circleColor,
        xLabel: '${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}',
      );
    }).toList();

    // Variabel yang menyimpan daftar label waktu dalam bentuk string
    List<String> _timeLabels = _generateTimeLabels(_seconds);

    return Scaffold(
      // AppBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 178, 255),
        title: const Text('Fish Finder'),
        // Button dengan icon arrow back yang menavigasi ke halaman sebelumnya
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigasi ke halaman sebelumnya
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Padding untuk scatter chart
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, right: 40.0, bottom: 45.0, left: 16.0),
                  child: ScatterChart(
                    ScatterChartData(
                      scatterSpots: spotsWithColors.map((e) => e.spot).toList(),
                      minX: 0,
                      maxX: 10,
                      minY: 0,
                      maxY: 10,
                      // Data untuk border
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 3),
                          bottom: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      // Data untuk grid
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        checkToShowHorizontalLine: (value) => value % 1 == 0,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300]!,
                        ),
                        drawVerticalLine: true,
                        checkToShowVerticalLine: (value) => false,
                      ),
                      // Data untuk titles
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Text(
                                  "${(100 - value * 10).toStringAsFixed(0)} m",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              return Text(_timeLabels[(value ~/ 2) % _timeLabels.length]);
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      // Data untuk interaksi touch pada scatter chart
                      scatterTouchData: ScatterTouchData(
                        enabled: false,
                        handleBuiltInTouches: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Class untuk menyimpan data titik dengan warna dan label X
class ScatterSpotWithColor {
  final ScatterSpot spot;
  final Color color;
  final String xLabel;

  ScatterSpotWithColor({
    required this.spot,
    required this.color,
    required this.xLabel,
  });
}