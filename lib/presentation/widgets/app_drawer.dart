import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Controla qual menu está expandido
  String? menuExpandido;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🐄',
                    style: TextStyle(fontSize: 48),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestão de Gado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sistema Completo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Dashboard
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    titulo: 'Dashboard',
                    rota: '/dashboard',
                    cor: Colors.teal,
                  ),

                  Divider(height: 1),

                  // Animais (com submenu)
                  _buildMenuExpansivel(
                    icon: Icons.pets,
                    titulo: 'Animais',
                    cor: Colors.blue,
                    identificador: 'animais',
                    subitens: [
                      _SubMenuItem(
                        titulo: 'Lista de Animais',
                        rota: '/animais',
                        icon: Icons.list,
                      ),
                      _SubMenuItem(
                        titulo: 'Cadastrar Animal',
                        rota: '/animais/form',
                        icon: Icons.add_circle_outline,
                      ),
                    ],
                  ),

                  // Grupos (com submenu)
                  _buildMenuExpansivel(
                    icon: Icons.folder,
                    titulo: 'Grupos',
                    cor: Colors.green,
                    identificador: 'grupos',
                    subitens: [
                      _SubMenuItem(
                        titulo: 'Lista de Grupos',
                        rota: '/grupos',
                        icon: Icons.list,
                      ),
                      _SubMenuItem(
                        titulo: 'Criar Grupo',
                        rota: '/grupos/form',
                        icon: Icons.add_circle_outline,
                      ),
                    ],
                  ),

                  // Pesagem (com submenu)
                  _buildMenuExpansivel(
                    icon: Icons.monitor_weight,
                    titulo: 'Pesagem',
                    cor: Colors.orange,
                    identificador: 'pesagem',
                    subitens: [
                      _SubMenuItem(
                        titulo: 'Registrar Pesagem',
                        rota: '/pesagem',
                        icon: Icons.add_circle_outline,
                      ),
                    ],
                  ),

                  // Saúde (com submenu)
                  _buildMenuExpansivel(
                    icon: Icons.medical_services,
                    titulo: 'Saúde',
                    cor: Colors.red,
                    identificador: 'saude',
                    subitens: [
                      _SubMenuItem(
                        titulo: 'Registrar Evento',
                        rota: '/saude',
                        icon: Icons.add_circle_outline,
                      ),
                      _SubMenuItem(
                        titulo: 'Alertas',
                        rota: '/alertas-saude',
                        icon: Icons.notifications_active,
                      ),
                      _SubMenuItem(
                        titulo: 'Relatório de Saúde',
                        rota: '/relatorio-saude',
                        icon: Icons.assignment,
                      ),
                    ],
                  ),

                  Divider(height: 1),

                  // Configurações
                  _buildMenuItem(
                    icon: Icons.settings,
                    titulo: 'Configurações',
                    rota: '/dashboard', // Placeholder
                    cor: Colors.grey,
                  ),

                  // Sobre
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    titulo: 'Sobre',
                    rota: '/dashboard', // Placeholder
                    cor: Colors.grey,
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'v1.0.0 - Sistema de Gestão',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Item de menu simples (sem submenu)
  Widget _buildMenuItem({
    required IconData icon,
    required String titulo,
    required String rota,
    required Color cor,
  }) {
    bool isAtual = Get.currentRoute == rota;

    return Container(
      color: isAtual ? cor.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isAtual ? cor : Colors.grey.shade600),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: isAtual ? FontWeight.bold : FontWeight.normal,
            color: isAtual ? cor : Colors.grey.shade800,
          ),
        ),
        onTap: () {
          Get.back(); // Fecha drawer
          if (Get.currentRoute != rota) {
            Get.toNamed(rota);
          }
        },
      ),
    );
  }

  // Item de menu expansível (com submenu)
  Widget _buildMenuExpansivel({
    required IconData icon,
    required String titulo,
    required Color cor,
    required String identificador,
    required List<_SubMenuItem> subitens,
  }) {
    bool expandido = menuExpandido == identificador;

    return Column(
      children: [
        Container(
          color: expandido ? cor.withOpacity(0.05) : Colors.transparent,
          child: ListTile(
            leading: Icon(icon, color: cor),
            title: Text(
              titulo,
              style: TextStyle(
                fontWeight: expandido ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey.shade800,
              ),
            ),
            trailing: Icon(
              expandido ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey.shade600,
            ),
            onTap: () {
              setState(() {
                if (expandido) {
                  menuExpandido = null;
                } else {
                  menuExpandido = identificador;
                }
              });
            },
          ),
        ),
        if (expandido)
          Container(
            color: cor.withOpacity(0.05),
            child: Column(
              children: subitens.map((subitem) {
                bool isAtual = Get.currentRoute == subitem.rota;
                return Container(
                  color: isAtual ? cor.withOpacity(0.15) : Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 72, right: 16),
                    leading: Icon(
                      subitem.icon,
                      size: 20,
                      color: isAtual ? cor : Colors.grey.shade600,
                    ),
                    title: Text(
                      subitem.titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isAtual ? FontWeight.bold : FontWeight.normal,
                        color: isAtual ? cor : Colors.grey.shade700,
                      ),
                    ),
                    onTap: () {
                      Get.back(); // Fecha drawer
                      if (Get.currentRoute != subitem.rota) {
                        Get.toNamed(subitem.rota);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// Classe auxiliar para subitens
class _SubMenuItem {
  final String titulo;
  final String rota;
  final IconData icon;

  _SubMenuItem({
    required this.titulo,
    required this.rota,
    required this.icon,
  });
}
