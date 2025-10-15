import 'package:get/get.dart';
import '../controllers/pesagem_controller.dart';

class PesagemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PesagemController());
  }
}
