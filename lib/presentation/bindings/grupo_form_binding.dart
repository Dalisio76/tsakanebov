import 'package:get/get.dart';
import '../controllers/grupo_form_controller.dart';

class GrupoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GrupoFormController());
  }
}
