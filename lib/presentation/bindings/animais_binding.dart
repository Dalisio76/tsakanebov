import 'package:get/get.dart';
import '../controllers/animais_controller.dart';

class AnimaisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AnimaisController());
  }
}
