import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  void irParaTeste() {
    Get.toNamed(AppRoutes.TESTE_CONEXAO);
  }
}
