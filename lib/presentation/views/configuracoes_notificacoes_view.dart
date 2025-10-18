import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfiguracoesNotificacoesView extends StatefulWidget {
  const ConfiguracoesNotificacoesView({super.key});

  @override
  State<ConfiguracoesNotificacoesView> createState() =>
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
  bool isLoadingConfigs = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoesExistentes();
  }

  Future<void> _carregarConfiguracoesExistentes() async {
    try {
      final response = await _supabase
          .from('configuracoes_notificacao')
          .select()
          .eq('ativo', true)
          .maybeSingle();

      if (response != null) {
        setState(() {
          tipoSelecionado = response['tipo'] ?? 'email';
          _emailController.text = response['destinatario'] ?? '';
          _telefoneController.text = response['destinatario'] ?? '';

          final eventos = response['eventos_ativos'] as List?;
          if (eventos != null) {
            eventosAtivos = eventos.map((e) => e.toString()).toSet();
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar configurações: $e');
    } finally {
      setState(() {
        isLoadingConfigs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingConfigs) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurar Notificações'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 Configurar Notificações'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de introdução
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Configure seu email para receber notificações automáticas sobre eventos importantes do sistema.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tipo de notificação
            const Text(
              'Como deseja receber notificações?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'email',
                  label: Text('Email'),
                  icon: Icon(Icons.email),
                ),
                ButtonSegment(
                  value: 'whatsapp',
                  label: Text('WhatsApp'),
                  icon: Icon(Icons.message),
                  enabled: false, // Desabilitado por enquanto
                ),
                ButtonSegment(
                  value: 'ambos',
                  label: Text('Ambos'),
                  icon: Icon(Icons.notifications_active),
                  enabled: false, // Desabilitado por enquanto
                ),
              ],
              selected: {tipoSelecionado},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  tipoSelecionado = newSelection.first;
                });
              },
            ),

            const SizedBox(height: 24),

            // Email
            if (tipoSelecionado == 'email' || tipoSelecionado == 'ambos') ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  helperText: 'Digite o email que receberá as notificações',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
            ],

            // WhatsApp (desabilitado)
            if (tipoSelecionado == 'whatsapp' || tipoSelecionado == 'ambos') ...[
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone WhatsApp',
                  hintText: '+258840000000',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  helperText: 'Formato: +258 seguido do número',
                ),
                keyboardType: TextInputType.phone,
                enabled: false,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'WhatsApp requer configuração do Twilio. Por enquanto apenas Email está disponível.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // Eventos
            const Text(
              'Eventos para notificar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Animal Cadastrado'),
                    subtitle: const Text('Notifica quando um novo animal é cadastrado'),
                    secondary: const Icon(Icons.pets, color: Colors.green),
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
                  const Divider(height: 1),
                  CheckboxListTile(
                    title: const Text('Animal Morto'),
                    subtitle: const Text('Notifica quando um animal é marcado como morto'),
                    secondary: const Icon(Icons.heart_broken, color: Colors.red),
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
                  const Divider(height: 1),
                  CheckboxListTile(
                    title: const Text('Pesagem Realizada'),
                    subtitle: const Text('Notifica quando uma pesagem é registrada'),
                    secondary: const Icon(Icons.monitor_weight, color: Colors.orange),
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
                  const Divider(height: 1),
                  CheckboxListTile(
                    title: const Text('Vacina Próxima'),
                    subtitle: const Text('Notifica quando uma vacina está próxima do vencimento'),
                    secondary: const Icon(Icons.vaccines, color: Colors.purple),
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
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _salvarConfiguracao,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Salvando...'),
                        ],
                      )
                    : const Text(
                        'Salvar Configuração',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Botão limpar configurações
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _limparConfiguracoes,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Desativar Notificações'),
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
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String destinatario = '';
    if (tipoSelecionado == 'email' || tipoSelecionado == 'ambos') {
      if (_emailController.text.trim().isEmpty) {
        Get.snackbar(
          '❌ Erro',
          'Informe o email',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validação básica de email
      if (!_emailController.text.contains('@')) {
        Get.snackbar(
          '❌ Erro',
          'Email inválido',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      destinatario = _emailController.text.trim();
    }

    if (tipoSelecionado == 'whatsapp' || tipoSelecionado == 'ambos') {
      if (_telefoneController.text.trim().isEmpty) {
        Get.snackbar(
          '❌ Erro',
          'Informe o telefone',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      destinatario = _telefoneController.text.trim();
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Desativar configurações antigas
      await _supabase
          .from('configuracoes_notificacao')
          .update({'ativo': false}).eq('ativo', true);

      // Inserir nova configuração
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
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Voltar após 1 segundo
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao salvar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _limparConfiguracoes() async {
    final confirmado = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja realmente desativar todas as notificações?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _supabase
          .from('configuracoes_notificacao')
          .update({'ativo': false}).eq('ativo', true);

      Get.snackbar(
        '✅ Sucesso',
        'Notificações desativadas',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      setState(() {
        _emailController.clear();
        _telefoneController.clear();
        eventosAtivos.clear();
      });
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao desativar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }
}
