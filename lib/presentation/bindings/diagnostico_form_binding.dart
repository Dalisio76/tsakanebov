import 'package:get/get.dart';
import '../controllers/diagnostico_form_controller.dart';

class DiagnosticoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiagnosticoFormController>(() => DiagnosticoFormController());
  }
}
