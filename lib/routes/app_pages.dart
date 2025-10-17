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
import 'package:tsakanebov/presentation/bindings/despesas_binding.dart'
    show DespesasBinding;
import 'package:tsakanebov/presentation/bindings/despesa_form_binding.dart'
    show DespesaFormBinding;
import 'package:tsakanebov/presentation/bindings/relatorio_custos_binding.dart'
    show RelatorioCustosBinding;
import 'package:tsakanebov/presentation/bindings/coberturas_binding.dart'
    show CoberturasBinding;
import 'package:tsakanebov/presentation/bindings/cobertura_form_binding.dart'
    show CoberturaFormBinding;
import 'package:tsakanebov/presentation/bindings/diagnosticos_binding.dart'
    show DiagnosticosBinding;
import 'package:tsakanebov/presentation/bindings/diagnostico_form_binding.dart'
    show DiagnosticoFormBinding;
import 'package:tsakanebov/presentation/bindings/partos_binding.dart'
    show PartosBinding;
import 'package:tsakanebov/presentation/bindings/parto_form_binding.dart'
    show PartoFormBinding;
import 'package:tsakanebov/presentation/bindings/relatorio_reproducao_binding.dart'
    show RelatorioReproducaoBinding;
import 'package:tsakanebov/presentation/bindings/dashboard_binding.dart'
    show DashboardBinding;
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
import 'package:tsakanebov/presentation/views/despesas_view.dart'
    show DespesasView;
import 'package:tsakanebov/presentation/views/despesa_form_view.dart'
    show DespesaFormView;
import 'package:tsakanebov/presentation/views/relatorio_custos_view.dart'
    show RelatorioCustosView;
import 'package:tsakanebov/presentation/views/coberturas_view.dart'
    show CoberturasView;
import 'package:tsakanebov/presentation/views/cobertura_form_view.dart'
    show CoberturaFormView;
import 'package:tsakanebov/presentation/views/diagnosticos_view.dart'
    show DiagnosticosView;
import 'package:tsakanebov/presentation/views/diagnostico_form_view.dart'
    show DiagnosticoFormView;
import 'package:tsakanebov/presentation/views/partos_view.dart'
    show PartosView;
import 'package:tsakanebov/presentation/views/parto_form_view.dart'
    show PartoFormView;
import 'package:tsakanebov/presentation/views/relatorio_reproducao_view.dart'
    show RelatorioReproducaoView;
import 'package:tsakanebov/presentation/views/dashboard_view.dart'
    show DashboardView;

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
    GetPage(
      name: AppRoutes.DESPESAS,
      page: () => DespesasView(),
      binding: DespesasBinding(),
    ),
    GetPage(
      name: AppRoutes.DESPESA_FORM,
      page: () => DespesaFormView(),
      binding: DespesaFormBinding(),
    ),
    GetPage(
      name: AppRoutes.RELATORIO_CUSTOS,
      page: () => RelatorioCustosView(),
      binding: RelatorioCustosBinding(),
    ),
    GetPage(
      name: AppRoutes.COBERTURAS,
      page: () => CoberturasView(),
      binding: CoberturasBinding(),
    ),
    GetPage(
      name: AppRoutes.COBERTURA_FORM,
      page: () => CoberturaFormView(),
      binding: CoberturaFormBinding(),
    ),
    GetPage(
      name: AppRoutes.DIAGNOSTICOS,
      page: () => DiagnosticosView(),
      binding: DiagnosticosBinding(),
    ),
    GetPage(
      name: AppRoutes.DIAGNOSTICO_FORM,
      page: () => DiagnosticoFormView(),
      binding: DiagnosticoFormBinding(),
    ),
    GetPage(
      name: AppRoutes.PARTOS,
      page: () => PartosView(),
      binding: PartosBinding(),
    ),
    GetPage(
      name: AppRoutes.PARTO_FORM,
      page: () => PartoFormView(),
      binding: PartoFormBinding(),
    ),
    GetPage(
      name: AppRoutes.RELATORIO_REPRODUCAO,
      page: () => RelatorioReproducaoView(),
      binding: RelatorioReproducaoBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
  ];
}
