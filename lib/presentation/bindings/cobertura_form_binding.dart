import 'package:get/get.dart';
import '../controllers/cobertura_form_controller.dart';

class CoberturaFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoberturaFormController>(() => CoberturaFormController());
  }
}
