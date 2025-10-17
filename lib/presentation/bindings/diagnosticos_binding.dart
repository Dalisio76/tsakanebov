import 'package:get/get.dart';
import '../controllers/diagnosticos_controller.dart';

class DiagnosticosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiagnosticosController>(() => DiagnosticosController());
  }
}
