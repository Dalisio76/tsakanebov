import 'package:get/get.dart';
import '../controllers/despesa_form_controller.dart';

class DespesaFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DespesaFormController>(() => DespesaFormController());
  }
}
