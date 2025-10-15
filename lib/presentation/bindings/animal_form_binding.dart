import 'package:get/get.dart';
import '../controllers/animal_form_controller.dart';

class AnimalFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnimalFormController());
  }
}
