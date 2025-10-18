import 'package:intl/intl.dart';

class CurrencyHelper {
  // Formatar como Metical
  static String formatMT(double valor) {
    return 'MT ${NumberFormat('#,##0.00', 'pt_BR').format(valor)}';
  }

  // Formatar peso
  static String formatPeso(double peso) {
    return '${NumberFormat('#,##0.0', 'pt_BR').format(peso)} kg';
  }

  // Formatar GMD (Ganho Médio Diário)
  static String formatGMD(double gmd) {
    return '${NumberFormat('#,##0.000', 'pt_BR').format(gmd)} kg/dia';
  }

  // Formatar número com separador de milhares
  static String formatNumber(double numero) {
    return NumberFormat('#,##0', 'pt_BR').format(numero);
  }
}
