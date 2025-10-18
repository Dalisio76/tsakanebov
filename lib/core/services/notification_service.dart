import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import '../config/supabase_config.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  // Configurações
  static const String emailAPIKey = 're_H2GjTXHA_FgtFJNK8pi8TWkLxSs4Ke2vR'; // Resend.com

  // URL da Edge Function do Supabase
  static const String edgeFunctionUrl =
      'https://sbfzqpcnmcftzcgxpkrl.supabase.co/functions/v1/enviar-email';

  // Para WhatsApp via Twilio (opcional - configure se quiser usar WhatsApp)
  static const String twilioSID = ''; // SEU_TWILIO_SID (deixe vazio por enquanto)
  static const String twilioToken = ''; // SEU_TWILIO_TOKEN
  static const String twilioWhatsAppFrom = ''; // whatsapp:+14155238886

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
    // Se na web e Edge Function configurada, usar Edge Function
    if (kIsWeb && edgeFunctionUrl.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse(edgeFunctionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
            'apikey': SupabaseConfig.anonKey,
          },
          body: json.encode({
            'destinatario': destinatario,
            'assunto': assunto,
            'mensagem': mensagem,
          }),
        );

        if (response.statusCode == 200) {
          await _registrarLog('email', destinatario, assunto, mensagem, 'enviada', null);
          print('✅ Email enviado via Edge Function para $destinatario');
        } else {
          await _registrarLog('email', destinatario, assunto, mensagem, 'erro', response.body);
          print('❌ Erro Edge Function: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        await _registrarLog('email', destinatario, assunto, mensagem, 'erro', e.toString());
        print('❌ Erro ao enviar via Edge Function: $e');
      }
      return;
    }

    // Se na web mas Edge Function não configurada
    if (kIsWeb) {
      print('⚠️ [WEB] Edge Function não configurada');
      print('📧 Para: $destinatario');
      print('📋 Assunto: $assunto');
      print('💬 Mensagem: $mensagem');

      await _registrarLog('email', destinatario, assunto, mensagem, 'pendente',
          'Edge Function não configurada.');
      return;
    }

    // Para mobile/desktop: chamada direta à API Resend
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
        print('❌ Erro ao enviar email: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      await _registrarLog('email', destinatario, assunto, mensagem, 'erro', e.toString());
      print('❌ Erro ao enviar email: $e');
    }
  }

  // Enviar WhatsApp via Twilio (desabilitado se não configurado)
  Future<void> _enviarWhatsApp(String destinatario, String mensagem) async {
    if (twilioSID.isEmpty || twilioToken.isEmpty) {
      print('⚠️ WhatsApp não configurado (Twilio). Pulando...');
      return;
    }

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
