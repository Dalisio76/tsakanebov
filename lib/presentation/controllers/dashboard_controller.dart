import 'package:get/get.dart';
import '../../core/utils/currency_helper.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/services/dashboard_service.dart';

class DashboardController extends GetxController {
  final _dashboardService = DashboardService();

  var isLoading = true.obs;
  var stats = Rx<DashboardStatsModel?>(null);
  var gruposStats = <GrupoStatsModel>[].obs;
  var evolucaoPeso = <EvolucaoPesoModel>[].obs;

  // Configurações da fazenda
  var hectaresFazenda = 100.0.obs; // Valor padrão, editável

  @override
  void onInit() {
    super.onInit();
    carregarDashboard();
  }

  Future<void> carregarDashboard() async {
    try {
      isLoading.value = true;

      // Carregar todos os dados em paralelo
      final results = await Future.wait([
        _dashboardService.buscarEstatisticas(),
        _dashboardService.buscarDadosPorGrupo(),
        _dashboardService.buscarEvolucaoPeso(),
      ]);

      stats.value = results[0] as DashboardStatsModel;
      gruposStats.value = results[1] as List<GrupoStatsModel>;
      evolucaoPeso.value = results[2] as List<EvolucaoPesoModel>;
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao carregar dashboard: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cálculos derivados
  double get unidadeAnimalPorHa {
    if (stats.value == null || hectaresFazenda.value == 0) return 0;
    // UA = Peso vivo total / 450kg / hectares
    return (stats.value!.pesoTotalKg / 450) / hectaresFazenda.value;
  }

  double get ganhoArrobaPorHa {
    if (stats.value == null || hectaresFazenda.value == 0) return 0;
    // @ / ha = (Peso total em arrobas) / hectares
    return stats.value!.arrobasTotal / hectaresFazenda.value;
  }

  double get mediaArrobasPorAnimal {
    if (stats.value == null || stats.value!.animaisAtivos == 0) return 0;
    return stats.value!.arrobasTotal / stats.value!.animaisAtivos;
  }

  // Formatar valores
  String formatarMoeda(double valor) {
    return CurrencyHelper.formatMT(valor);
  }

  String formatarPeso(double peso) {
    return CurrencyHelper.formatPeso(peso);
  }

  String formatarGMD(double gmd) {
    return CurrencyHelper.formatGMD(gmd);
  }

  // Atualizar hectares
  void atualizarHectares(double novosHectares) {
    hectaresFazenda.value = novosHectares;
  }
}
