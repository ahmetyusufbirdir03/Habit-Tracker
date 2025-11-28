import 'package:logger/logger.dart';

final logger = Logger(

  printer: PrettyPrinter(
    methodCount: 0,        // Stack trace satırı yok
    errorMethodCount: 0,   // Hatalarda trace göstermesin
    lineLength: 80,        // Satır uzunluğu
    colors: true,          // Renkli çıktı
    printEmojis: true,     // Emojili seviye göstergesi
    printTime: true,
  ),
);