import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/registro_saude_model.dart';
import '../../data/models/tipo_evento_saude_model.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/registro_saude_service.dart';
import '../../data/services/tipo_evento_saude_service.dart';

class RelatorioSaudeController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final RegistroSaudeService _saudeService = RegistroSaudeService();
  final TipoEventoSaudeService _tipoService = TipoEventoSaudeService();

  var registros = <RegistroSaudeModel>[].obs;
  var tiposEvento = <TipoEventoSaudeModel>[].obs;
  var isLoading = false.obs;

  // Filtros
  var tipoSelecionado = Rxn<String>();
  var diasFiltro = 30.obs;

  @override
  void onInit() {
    super.onInit();
    carregarTipos();
    carregarRegistros();
  }

  Future<void> carregarTipos() async {
    try {
      tiposEvento.value = await _tipoService.listarTodos();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> carregarRegistros() async {
    try {
      isLoading.value = true;
      registros.value = await _saudeService.listarRecentes(
        dias: diasFiltro.value,
      );

      // Aplicar filtro de tipo se selecionado
      if (tipoSelecionado.value != null) {
        registros.value = registros
            .where((r) => r.tipoEventoId == tipoSelecionado.value)
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar registros: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void alterarFiltro(int dias) {
    diasFiltro.value = dias;
    carregarRegistros();
  }

  void filtrarPorTipo(String? tipoId) {
    tipoSelecionado.value = tipoId;
    carregarRegistros();
  }

  void limparFiltros() {
    tipoSelecionado.value = null;
    diasFiltro.value = 30;
    carregarRegistros();
  }

  // Agrupar por tipo
  Map<String, List<RegistroSaudeModel>> get registrosPorTipo {
    final Map<String, List<RegistroSaudeModel>> agrupados = {};

    for (var registro in registros) {
      final tipo = registro.tipoEventoNome ?? 'Outros';
      if (!agrupados.containsKey(tipo)) {
        agrupados[tipo] = [];
      }
      agrupados[tipo]!.add(registro);
    }

    return agrupados;
  }

  // Estatísticas
  int get totalEventos => registros.length;

  double get custoTotal {
    return registros.fold(0.0, (sum, r) => sum + (r.custo ?? 0.0));
  }

  int get totalAnimais {
    return registros.map((r) => r.animalId).toSet().length;
  }

  Future<void> verHistoricoAnimal(String animalId) async {
    try {
      final animal = await _animalService.buscarPorId(animalId);

      if (animal != null) {
        Get.toNamed('/historico-saude', arguments: animal);
      } else {
        Get.snackbar('Erro', 'Animal não encontrado');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar animal: $e');
    }
  }
}
