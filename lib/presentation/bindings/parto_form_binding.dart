import 'package:get/get.dart';
import '../controllers/parto_form_controller.dart';

class PartoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartoFormController>(() => PartoFormController());
  }
}
