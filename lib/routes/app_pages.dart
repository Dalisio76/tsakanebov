import 'package:get/get.dart';
import 'package:tsakanebov/presentation/bindings/home_binding.dart'
    show HomeBinding;
import 'package:tsakanebov/presentation/bindings/teste_binding.dart'
    show TesteBinding;
import 'package:tsakanebov/presentation/bindings/grupos_binding.dart'
    show GruposBinding;
import 'package:tsakanebov/presentation/bindings/grupo_form_binding.dart'
    show GrupoFormBinding;
import 'package:tsakanebov/presentation/bindings/animais_binding.dart'
    show AnimaisBinding;
import 'package:tsakanebov/presentation/bindings/animal_form_binding.dart'
    show AnimalFormBinding;
import 'package:tsakanebov/presentation/bindings/pesagem_binding.dart'
    show PesagemBinding;
import 'package:tsakanebov/presentation/bindings/historico_pesagem_binding.dart'
    show HistoricoPesagemBinding;
import 'package:tsakanebov/presentation/bindings/saude_binding.dart'
    show SaudeBinding;
import 'package:tsakanebov/presentation/bindings/historico_saude_binding.dart'
    show HistoricoSaudeBinding;
import 'package:tsakanebov/presentation/bindings/alertas_saude_binding.dart'
    show AlertasSaudeBinding;
import 'package:tsakanebov/presentation/bindings/relatorio_saude_binding.dart'
    show RelatorioSaudeBinding;
import 'package:tsakanebov/presentation/views/home_view.dart' show HomeView;
import 'package:tsakanebov/presentation/views/teste_conexao_view.dart'
    show TesteConexaoView;
import 'package:tsakanebov/presentation/views/grupos_view.dart'
    show GruposView;
import 'package:tsakanebov/presentation/views/grupo_form_view.dart'
    show GrupoFormView;
import 'package:tsakanebov/presentation/views/animais_view.dart'
    show AnimaisView;
import 'package:tsakanebov/presentation/views/animal_form_view.dart'
    show AnimalFormView;
import 'package:tsakanebov/presentation/views/animal_detalhes_view.dart'
    show AnimalDetalhesView;
import 'package:tsakanebov/presentation/views/pesagem_view.dart'
    show PesagemView;
import 'package:tsakanebov/presentation/views/historico_pesagem_view.dart'
    show HistoricoPesagemView;
import 'package:tsakanebov/presentation/views/saude_view.dart'
    show SaudeView;
import 'package:tsakanebov/presentation/views/historico_saude_view.dart'
    show HistoricoSaudeView;
import 'package:tsakanebov/presentation/views/alertas_saude_view.dart'
    show AlertasSaudeView;
import 'package:tsakanebov/presentation/views/relatorio_saude_view.dart'
    show RelatorioSaudeView;

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.TESTE_CONEXAO,
      page: () => TesteConexaoView(),
      binding: TesteBinding(),
    ),
    GetPage(
      name: AppRoutes.GRUPOS,
      page: () => const GruposView(),
      binding: GruposBinding(),
    ),
    GetPage(
      name: AppRoutes.GRUPO_FORM,
      page: () => const GrupoFormView(),
      binding: GrupoFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ANIMAIS,
      page: () => const AnimaisView(),
      binding: AnimaisBinding(),
    ),
    GetPage(
      name: AppRoutes.ANIMAL_FORM,
      page: () => const AnimalFormView(),
      binding: AnimalFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ANIMAL_DETALHES,
      page: () => const AnimalDetalhesView(),
    ),
    GetPage(
      name: AppRoutes.PESAGEM,
      page: () => const PesagemView(),
      binding: PesagemBinding(),
    ),
    GetPage(
      name: AppRoutes.HISTORICO_PESAGEM,
      page: () => const HistoricoPesagemView(),
      binding: HistoricoPesagemBinding(),
    ),
    GetPage(
      name: AppRoutes.SAUDE,
      page: () => const SaudeView(),
      binding: SaudeBinding(),
    ),
    GetPage(
      name: AppRoutes.HISTORICO_SAUDE,
      page: () => const HistoricoSaudeView(),
      binding: HistoricoSaudeBinding(),
    ),
    GetPage(
      name: AppRoutes.ALERTAS_SAUDE,
      page: () => const AlertasSaudeView(),
      binding: AlertasSaudeBinding(),
    ),
    GetPage(
      name: AppRoutes.RELATORIO_SAUDE,
      page: () => const RelatorioSaudeView(),
      binding: RelatorioSaudeBinding(),
    ),
  ];
}
