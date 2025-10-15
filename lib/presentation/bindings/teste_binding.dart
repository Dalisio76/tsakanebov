import 'package:get/get.dart';
import '../controllers/teste_controller.dart';

class TesteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TesteController());
  }
}
