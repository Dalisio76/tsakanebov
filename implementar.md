# 🎨 VIEW DETALHES PROFISSIONAL + NOTIFICAÇÕES

## 📦 PARTE 1: VIEW DETALHES REDESENHADA

### Criar `lib/presentation/views/animal_detalhes_view_new.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/animal_model.dart';
import '../widgets/app_drawer.dart';

class AnimalDetalhesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AnimalModel animal = Get.arguments as AnimalModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar com imagem expandida
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Brinco ${animal.brinco}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem do animal
                  animal.urlImagem != null && animal.urlImagem!.isNotEmpty
                      ? Image.network(
                          animal.urlImagem!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultImage(animal);
                          },
                        )
                      : _buildDefaultImage(animal),
                  
                  // Gradiente para melhorar legibilidade
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Botão editar
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Get.toNamed('/animal-form', arguments: animal);
                },
                tooltip: 'Editar',
              ),
              // Menu de opções
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'compartilhar') {
                    // TODO: Implementar compartilhamento
                    Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
                  } else if (value == 'imprimir') {
                    // TODO: Implementar impressão
                    Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'compartilhar',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Compartilhar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'imprimir',
                    child: Row(
                      children: [
                        Icon(Icons.print, size: 20),
                        SizedBox(width: 8),
                        Text('Imprimir Ficha'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Badge de status
                _buildStatusBadge(animal),

                // Cards de informação
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações principais em cards grandes
                      _buildMainInfoCards(animal),
                      
                      SizedBox(height: 24),

                      // Identificação
                      _buildSectionHeader('Identificação', Icons.badge),
                      SizedBox(height: 12),
                      _buildInfoCard([
                        _InfoRow('Brinco', animal.brinco, Icons.tag),
                        if (animal.nome != null)
                          _InfoRow('Nome', animal.nome!, Icons.pets),
                        _InfoRow('Sexo', animal.sexoIcon, Icons.male),
                        if (animal.raca != null)
                          _InfoRow('Raça', animal.raca!, Icons.pets),
                        if (animal.tipoPele != null)
                          _InfoRow('Tipo de Pele', animal.tipoPele!, Icons.palette),
                      ]),

                      SizedBox(height: 24),

                      // Dados físicos
                      _buildSectionHeader('Dados Físicos', Icons.monitor_weight),
                      SizedBox(height: 12),
                      _buildPhysicalDataCards(animal),

                      SizedBox(height: 24),

                      // Genealogia
                      if (animal.paiBrinco != null || animal.maeBrinco != null) ...[
                        _buildSectionHeader('Genealogia', Icons.family_restroom),
                        SizedBox(height: 12),
                        _buildGenealogyCard(animal),
                        SizedBox(height: 24),
                      ],

                      // Grupo
                      if (animal.grupoNome != null) ...[
                        _buildSectionHeader('Grupo/Lote', Icons.folder),
                        SizedBox(height: 12),
                        _buildGroupCard(animal),
                        SizedBox(height: 24),
                      ],

                      // Ações rápidas
                      _buildSectionHeader('Ações Rápidas', Icons.bolt),
                      SizedBox(height: 12),
                      _buildQuickActions(animal),

                      SizedBox(height: 24),

                      // Observações
                      if (animal.observacoes != null) ...[
                        _buildSectionHeader('Observações', Icons.note),
                        SizedBox(height: 12),
                        _buildObservationsCard(animal),
                        SizedBox(height: 24),
                      ],

                      // Informações do sistema
                      _buildSectionHeader('Sistema', Icons.info_outline),
                      SizedBox(height: 12),
                      _buildSystemInfoCard(animal),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Imagem padrão quando não tem foto
  Widget _buildDefaultImage(AnimalModel animal) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: animal.sexo == 'M'
              ? [Colors.blue.shade700, Colors.blue.shade400]
              : [Colors.pink.shade700, Colors.pink.shade400],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 120,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: 16),
            Text(
              animal.sexo == 'M' ? '♂️ Macho' : '♀️ Fêmea',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Badge de status
  Widget _buildStatusBadge(AnimalModel animal) {
    Color cor;
    String texto;
    IconData icone;

    switch (animal.status) {
      case 'ativo':
        cor = Colors.green;
        texto = 'Ativo';
        icone = Icons.check_circle;
        break;
      case 'morto':
        cor = Colors.grey.shade800;
        texto = 'Morto';
        icone = Icons.heart_broken;
        break;
      case 'vendido':
        cor = Colors.blue;
        texto = 'Vendido';
        icone = Icons.shopping_cart;
        break;
      case 'abate':
        cor = Colors.brown;
        texto = 'Para Abate';
        icone = Icons.restaurant;
        break;
      default:
        cor = Colors.grey;
        texto = animal.status ?? 'Desconhecido';
        icone = Icons.help;
    }

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Cards principais com destaque
  Widget _buildMainInfoCards(AnimalModel animal) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Idade',
            '${animal.idadeMeses ?? 0}',
            'meses',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Peso',
            animal.pesoAtualKg != null
                ? animal.pesoAtualKg!.toStringAsFixed(1)
                : '--',
            'kg',
            Icons.monitor_weight,
            Colors.orange,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Arrobas',
            animal.pesoAtualKg != null
                ? (animal.pesoAtualKg! / 15).toStringAsFixed(1)
                : '--',
            '@',
            Icons.scale,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Header de seção
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Divider(thickness: 2, color: Colors.green.shade700),
        ),
      ],
    );
  }

  // Card genérico de informações
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: child,
                ))
            .toList(),
      ),
    );
  }

  // Dados físicos em cards horizontais
  Widget _buildPhysicalDataCards(AnimalModel animal) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'Nascimento',
                DateFormat('dd/MM/yyyy').format(animal.dataNascimento),
                Icons.cake,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMiniStatCard(
                'Última Pesagem',
                animal.dataUltimaPesagem != null
                    ? DateFormat('dd/MM/yyyy').format(animal.dataUltimaPesagem!)
                    : 'Nunca',
                Icons.calendar_month,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Card de genealogia
  Widget _buildGenealogyCard(AnimalModel animal) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (animal.paiBrinco != null) ...[
                _buildParentBadge('♂️ Pai', animal.paiBrinco!, Colors.blue),
                SizedBox(width: 16),
              ],
              Text('×', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              if (animal.maeBrinco != null)
                _buildParentBadge('♀️ Mãe', animal.maeBrinco!, Colors.pink),
            ],
          ),
          if (animal.paiBrinco == null && animal.maeBrinco == null)
            Text(
              'Genealogia não informada',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildParentBadge(String label, String brinco, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            brinco,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Card de grupo
  Widget _buildGroupCard(AnimalModel animal) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grupo/Lote',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  animal.grupoNome!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  // Ações rápidas
  Widget _buildQuickActions(AnimalModel animal) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Pesar',
            Icons.monitor_weight,
            Colors.orange,
            () {
              Get.toNamed('/pesagem', arguments: animal);
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Histórico Peso',
            Icons.timeline,
            Colors.blue,
            () {
              Get.toNamed('/historico-pesagem', arguments: animal);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card de observações
  Widget _buildObservationsCard(AnimalModel animal) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note, color: Colors.amber.shade800),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              animal.observacoes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Informações do sistema
  Widget _buildSystemInfoCard(AnimalModel animal) {
    return _buildInfoCard([
      if (animal.criadoEm != null)
        _InfoRow(
          'Cadastrado em',
          DateFormat('dd/MM/yyyy HH:mm').format(animal.criadoEm!),
          Icons.add_circle_outline,
        ),
      if (animal.atualizadoEm != null)
        _InfoRow(
          'Última atualização',
          DateFormat('dd/MM/yyyy HH:mm').format(animal.atualizadoEm!),
          Icons.update,
        ),
    ]);
  }
}

// Widget auxiliar para linhas de informação
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## 📦 PARTE 2: SISTEMA DE NOTIFICAÇÕES

### A. Criar tabela de notificações no Supabase

```sql
-- Tabela de configurações de notificação
CREATE TABLE configuracoes_notificacao (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo VARCHAR(50) NOT NULL, -- email, whatsapp, ambos
  destinatario VARCHAR(255) NOT NULL, -- email ou telefone
  eventos_ativos TEXT[] NOT NULL, -- array: animal_cadastrado, animal_morto, pesagem, vacina_proxima
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Tabela de log de notificações enviadas
CREATE TABLE log_notificacoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo_notificacao VARCHAR(50) NOT NULL,
  destinatario VARCHAR(255) NOT NULL,
  metodo VARCHAR(20) NOT NULL, -- email, whatsapp
  assunto TEXT,
  mensagem TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'enviada', -- enviada, erro, pendente
  erro TEXT,
  enviado_em TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_log_notificacoes_data ON log_notificacoes(enviado_em DESC);
CREATE INDEX idx_config_ativo ON configuracoes_notificacao(ativo) WHERE ativo = TRUE;
```

---

### B. Criar serviço de notificações

#### Criar `lib/core/services/notification_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final _supabase = Supabase.instance.client;

  // Configurações (VOCÊ DEVE CONFIGURAR)
  static const String emailAPIKey = 'SUA_CHAVE_RESEND_API'; // Resend.com
  static const String twilioSID = 'SEU_TWILIO_SID';
  static const String twilioToken = 'SEU_TWILIO_TOKEN';
  static const String twilioWhatsAppFrom = 'whatsapp:+14155238886'; // Sandbox Twilio

  // Enviar notificação de animal cadastrado
  Future<void> notificarAnimalCadastrado(String brinco, String? nome) async {
    try {
      final configs = await _buscarConfiguracoes('animal_cadastrado');
      
      for (var config in configs) {
        String mensagem = '🐄 Novo animal cadastrado!\n\n'
            'Brinco: $brinco\n'
            '${nome != null ? 'Nome: $nome\n' : ''}'
            'Data: ${DateTime.now().toString().substring(0, 16)}';

        if (config['tipo'] == 'email' || config['tipo'] == 'ambos') {
          await _enviarEmail(
            config['destinatario'],
            'Novo Animal Cadastrado - $brinco',
            mensagem,
          );
        }

        if (config['tipo'] == 'whatsapp' || config['tipo'] == 'ambos') {
          await _enviarWhatsApp(
            config['destinatario'],
            mensagem,
          );
        }
      }
    } catch (e) {
      print('Erro ao notificar animal cadastrado: $e');
    }
  }

  // Notificar animal morto
  Future<void> notificarAnimalMorto(String brinco, String? nome) async {
    try {
      final configs = await _buscarConfiguracoes('animal_morto');
      
      for (var config in configs) {
        String mensagem = '💀 Animal marcado como morto\n\n'
            'Brinco: $brinco\n'
            '${nome != null ? 'Nome: $nome\n' : ''}'
            'Data: ${DateTime.now().toString().substring(0, 16)}';

        if (config['tipo'] == 'email' || config['tipo'] == 'ambos') {
          await _enviarEmail(
            config['destinatario'],
            '⚠️ Animal Morto - $brinco',
            mensagem,
          );
        }

        if (config['tipo'] == 'whatsapp' || config['tipo'] == 'ambos') {
          await _enviarWhatsApp(
            config['destinatario'],
            mensagem,
          );
        }
      }
    } catch (e) {
      print('Erro ao notificar animal morto: $e');
    }
  }

  // Notificar pesagem realizada
  Future<void> notificarPesagem(String brinco, double peso, double? gmd) async {
    try {
      final configs = await _buscarConfiguracoes('pesagem');
      
      for (var config in configs) {
        String mensagem = '⚖️ Nova pesagem registrada!\n\n'
            'Brinco: $brinco\n'
            'Peso: ${peso.toStringAsFixed(1)} kg\n'
            '${gmd != null ? 'GMD: ${gmd.toStringAsFixed(3)} kg/dia\n' : ''}'
            'Data: ${DateTime.now().toString().substring(0, 16)}';

        if (config['tipo'] == 'email' || config['tipo'] == 'ambos') {
          await _enviarEmail(
            config['destinatario'],
            'Nova Pesagem - $brinco',
            mensagem,
          );
        }

        if (config['tipo'] == 'whatsapp' || config['tipo'] == 'ambos') {
          await _enviarWhatsApp(
            config['destinatario'],
            mensagem,
          );
        }
      }
    } catch (e) {
      print('Erro ao notificar pesagem: $e');
    }
  }

  // Notificar vacina próxima
  Future<void> notificarVacinaProxima(String brinco, String tipoVacina, int diasRestantes) async {
    try {
      final configs = await _buscarConfiguracoes('vacina_proxima');
      
      for (var config in configs) {
        String mensagem = '💉 Alerta de vacina!\n\n'
            'Animal: $brinco\n'
            'Vacina: $tipoVacina\n'
            'Dias restantes: $diasRestantes\n'
            'Data: ${DateTime.now().toString().substring(0, 16)}';

        if (config['tipo'] == 'email' || config['tipo'] == 'ambos') {
          await _enviarEmail(
            config['destinatario'],
            '⚠️ Vacina Próxima - $brinco',
            mensagem,
          );
        }

        if (config['tipo'] == 'whatsapp' || config['tipo'] == 'ambos') {
          await _enviarWhatsApp(
            config['destinatario'],
            mensagem,
          );
        }
      }
    } catch (e) {
      print('Erro ao notificar vacina: $e');
    }
  }

  // Buscar configurações ativas para um tipo de evento
  Future<List<Map<String, dynamic>>> _buscarConfiguracoes(String evento) async {
    try {
      final response = await _supabase
          .from('configuracoes_notificacao')
          .select()
          .eq('ativo', true)
          .contains('eventos_ativos', [evento]);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar configurações: $e');
      return [];
    }
  }

  // Enviar email via Resend
  Future<void> _enviarEmail(String destinatario, String assunto, String mensagem) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $emailAPIKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'from': 'Sistema Gestão Gado <onboarding@resend.dev>',
          'to': [destinatario],
          'subject': assunto,
          'text': mensagem,
        }),
      );

      if (response.statusCode == 200) {
        await _registrarLog('email', destinatario, assunto, mensagem, 'enviada', null);
        print('✅ Email enviado para $destinatario');
      } else {
        await _registrarLog('email', destinatario, assunto, mensagem, 'erro', response.body);
        print('❌ Erro ao enviar email: ${response.statusCode}');
      }
    } catch (e) {
      await _registrarLog('email', destinatario, assunto, mensagem, 'erro', e.toString());
      print('❌ Erro ao enviar email: $e');
    }
  }

  // Enviar WhatsApp via Twilio
  Future<void> _enviarWhatsApp(String destinatario, String mensagem) async {
    try {
      final auth = base64Encode(utf8.encode('$twilioSID:$twilioToken'));
      
      final response = await http.post(
        Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$twilioSID/Messages.json'),
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': twilioWhatsAppFrom,
          'To': 'whatsapp:$destinatario',
          'Body': mensagem,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _registrarLog('whatsapp', destinatario, null, mensagem, 'enviada', null);
        print('✅ WhatsApp enviado para $destinatario');
      } else {
        await _registrarLog('whatsapp', destinatario, null, mensagem, 'erro', response.body);
        print('❌ Erro ao enviar WhatsApp: ${response.statusCode}');
      }
    } catch (e) {
      await _registrarLog('whatsapp', destinatario, null, mensagem, 'erro', e.toString());
      print('❌ Erro ao enviar WhatsApp: $e');
    }
  }

  // Registrar log de notificação
  Future<void> _registrarLog(
    String metodo,
    String destinatario,
    String? assunto,
    String mensagem,
    String status,
    String? erro,
  ) async {
    try {
      await _supabase.from('log_notificacoes').insert({
        'tipo_notificacao': assunto ?? 'notificacao',
        'destinatario': destinatario,
        'metodo': metodo,
        'assunto': assunto,
        'mensagem': mensagem,
        'status': status,
        'erro': erro,
      });
    } catch (e) {
      print('Erro ao registrar log: $e');
    }
  }
}
```

---

### C. Integrar notificações nos controllers

#### Editar `lib/presentation/controllers/animal_form_controller.dart`

```dart
// Adicionar import no topo
import '../../core/services/notification_service.dart';

// Adicionar instância do serviço
final _notificationService = NotificationService();

// No método salvar(), após sucesso:
if (isEditMode.value) {
  // ... código existente de update
} else {
  await _animalService.criar(animal);
  
  // ← ADICIONAR NOTIFICAÇÃO
  await _notificationService.notificarAnimalCadastrado(
    animal.brinco,
    animal.nome,
  );
  
  Get.snackbar(...); // mensagem de sucesso existente
}
```

---

#### Editar `lib/presentation/views/animais_view.dart`

```dart
// Adicionar import no topo
import '../../core/services/notification_service.dart';

// No método _marcarComoMorto, após atualizar:
await controller.animalService.atualizar(
  animal.id!,
  animal.copyWith(status: 'morto'),
);

// ← ADICIONAR NOTIFICAÇÃO
final notificationService = NotificationService();
await notificationService.notificarAnimalMorto(
  animal.brinco,
  animal.nome,
);
```

---

#### Editar `lib/presentation/controllers/pesagem_controller.dart`

```dart
// Adicionar import no topo
import '../../core/services/notification_service.dart';

// Adicionar instância
final _notificationService = NotificationService();

// No método registrarPesagem(), após sucesso:
await _pesagemService.registrarPesagem(pesagem);

// ← ADICIONAR NOTIFICAÇÃO
await _notificationService.notificarPesagem(
  animalSelecionado.value!.brinco,
  double.parse(pesoController.text),
  null, // GMD será calculado pelo banco
);
```

---

## 📦 PARTE 3: TELA DE CONFIGURAÇÕES

### Criar `lib/presentation/views/configuracoes_notificacoes_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';

class ConfiguracoesNotificacoesView extends StatefulWidget {
  @override
  _ConfiguracoesNotificacoesViewState createState() =>
      _ConfiguracoesNotificacoesViewState();
}

class _ConfiguracoesNotificacoesViewState
    extends State<ConfiguracoesNotificacoesView> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  String tipoSelecionado = 'email';
  Set<String> eventosAtivos = {};

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔔 Configurar Notificações'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de notificação
            Text(
              'Como deseja receber notificações?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'email',
                  label: Text('Email'),
                  icon: Icon(Icons.email),
                ),
                ButtonSegment(
                  value: 'whatsapp',
                  label: Text('WhatsApp'),
                  icon: Icon(Icons.message),
                ),
                ButtonSegment(
                  value: 'ambos',
                  label: Text('Ambos'),
                  icon: Icon(Icons.notifications_active),
                ),
              ],
              selected: {tipoSelecionado},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  tipoSelecionado = newSelection.first;
                });
              },
            ),

            SizedBox(height: 24),

            // Email
            if (tipoSelecionado == 'email' || tipoSelecionado == 'ambos') ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
            ],

            // WhatsApp
            if (tipoSelecionado == 'whatsapp' || tipoSelecionado == 'ambos') ...[
              TextField(
                controller: _telefoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone WhatsApp',
                  hintText: '+258840000000',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
            ],

            SizedBox(height: 24),

            // Eventos
            Text(
              'Eventos para notificar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            CheckboxListTile(
              title: Text('Animal Cadastrado'),
              subtitle: Text('Notifica quando um novo animal é cadastrado'),
              value: eventosAtivos.contains('animal_cadastrado'),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    eventosAtivos.add('animal_cadastrado');
                  } else {
                    eventosAtivos.remove('animal_cadastrado');
                  }
                });
              },
            ),

            CheckboxListTile(
              title: Text('Animal Morto'),
              subtitle: Text('Notifica quando um animal é marcado como morto'),
              value: eventosAtivos.contains('animal_morto'),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    eventosAtivos.add('animal_morto');
                  } else {
                    eventosAtivos.remove('animal_morto');
                  }
                });
              },
            ),

            CheckboxListTile(
              title: Text('Pesagem Realizada'),
              subtitle: Text('Notifica quando uma pesagem é registrada'),
              value: eventosAtivos.contains('pesagem'),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    eventosAtivos.add('pesagem');
                  } else {
                    eventosAtivos.remove('pesagem');
                  }
                });
              },
            ),

            CheckboxListTile(
              title: Text('Vacina Próxima'),
              subtitle: Text('Notifica quando uma vacina está próxima do vencimento'),
              value: eventosAtivos.contains('vacina_proxima'),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    eventosAtivos.add('vacina_proxima');
                  } else {
                    eventosAtivos.remove('vacina_proxima');
                  }
                });
              },
            ),

            SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _salvarConfiguracao,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Salvar Configuração', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarConfiguracao() async {
    if (eventosAtivos.isEmpty) {
      Get.snackbar(
        '⚠️ Atenção',
        'Selecione pelo menos um evento para notificar',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    String destinatario = '';
    if (tipoSelecionado == 'email' || tipoSelecionado == 'ambos') {
      if (_emailController.text.trim().isEmpty) {
        Get.snackbar('❌ Erro', 'Informe o email');
        return;
      }
      destinatario = _emailController.text.trim();
    }

    if (tipoSelecionado == 'whatsapp' || tipoSelecionado == 'ambos') {
      if (_telefoneController.text.trim().isEmpty) {
        Get.snackbar('❌ Erro', 'Informe o telefone');
        return;
      }
      destinatario = _telefoneController.text.trim();
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _supabase.from('configuracoes_notificacao').insert({
        'tipo': tipoSelecionado,
        'destinatario': destinatario,
        'eventos_ativos': eventosAtivos.toList(),
      });

      Get.snackbar(
        '✅ Sucesso',
        'Configuração salva com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao salvar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
```

---

## ✅ CHECKLIST COMPLETO

### View Detalhes:
- [ ] Criar `animal_detalhes_view_new.dart`
- [ ] Substituir rota em `app_pages.dart`

### Notificações - SQL:
- [ ] Executar SQL (criar tabelas)

### Notificações - Código:
- [ ] Criar `notification_service.dart`
- [ ] Editar `animal_form_controller.dart`
- [ ] Editar `animais_view.dart`
- [ ] Editar `pesagem_controller.dart`
- [ ] Criar `configuracoes_notificacoes_view.dart`
- [ ] Adicionar rota em `app_routes.dart`
- [ ] Adicionar página em `app_pages.dart`
- [ ] Adicionar item no menu

### Configurar APIs:
- [ ] Criar conta Resend.com (email)
- [ ] Criar conta Twilio (WhatsApp)
- [ ] Atualizar credenciais em `notification_service.dart`

---

## 🔧 CONFIGURAR APIS

### Email (Resend.com):
```
1. https://resend.com → Sign Up
2. API Keys → Create
3. Copiar chave
4. Colar em notification_service.dart
```

### WhatsApp (Twilio):
```
1. https://twilio.com → Sign Up
2. Console → WhatsApp → Sandbox
3. Copiar SID, Token e número
4. Colar em notification_service.dart
5. Ativar sandbox enviando código
```

---

## 💬 PRÓXIMOS PASSOS

Me avise quando implementar para criarmos:
1. ✅ Mais melhorias visuais
2. ✅ Sistema de Login
3. ✅ Relatórios PDF

Implemente e teste! 🎨📱✨