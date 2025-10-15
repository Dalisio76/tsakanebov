import 'package:get/get.dart';
import '../controllers/grupos_controller.dart';

class GruposBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GruposController());
  }
}
