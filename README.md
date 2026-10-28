# Flow — Sistema de Cronograma em Dart & Flutter

Um aplicativo de agenda pessoal responsivo, em português, com **painel de produtividade, calendário, lista de atividades, filtros e dados salvos no dispositivo**.

## Funcionalidades

- Painel com estatísticas, progresso semanal e agenda diária.
- Navegação por semanas e calendário mensal interativo.
- Cadastro, edição e exclusão de atividades, com ação **Desfazer**.
- Conclusão de atividades, categoria e prioridade.
- Busca por título, descrição ou categoria e filtros por status/categoria.
- Data e horário de início/fim com validação e aviso de conflito de agenda.
- Persistência offline com `SharedPreferencesAsync` (`shared_preferences` 2.5.x).
- Interface Material 3 responsiva: menu lateral em telas grandes e navegação inferior em celulares.
- Atividades de exemplo **somente no primeiro uso** (podem ser apagadas).

## Como executar

**Pré-requisitos:** SDK Flutter instalado, Chrome ou emulador/dispositivo configurado.

1. Extraia a pasta `cronograma_flow`.
2. Abra um terminal dentro dela.
3. Gere os arquivos de plataforma ausentes da distribuição de código-fonte:

   ```bash
   flutter create --project-name cronograma_flow --platforms=web,android .
   ```

   *Para iOS ou desktop, acrescente `ios`, `windows`, `linux` ou `macos` às plataformas, conforme seu sistema operacional. Para testar só no Chrome, use `--platforms=web`.*

4. Instale dependências e rode:

   ```bash
   flutter pub get
   flutter run -d chrome
   ```

   Para Android, `flutter run` com um emulador ou telefone conectado.

5. (Opcional) Confira o código e os testes:

   ```bash
   flutter analyze
   flutter test
   ```

> A distribuição inclui código-fonte, `pubspec.yaml`, testes e instruções; a pasta nativa de cada plataforma é gerada pelo próprio Flutter com `flutter create .`. Não inclui APK compilado.

## Organização

```text
lib/
  main.dart                       # inicialização e configuração pt-BR
  controllers/schedule_controller.dart  # estado, filtros, regras e persistência
  core/app_theme.dart             # visual Material 3
  core/date_utils.dart            # datas e formatação
  data/schedule_repository.dart   # serialização JSON e armazenamento
  models/schedule_item.dart       # modelo, categorias e prioridades
  screens/home_screen.dart        # painel, agenda, calendário, listagem
  widgets/task_editor.dart        # formulário de criação/edição
  widgets/ui_elements.dart        # cartões e componentes reutilizáveis
test/
  schedule_item_test.dart
```

## Considerações

- Dados são mantidos **localmente, por instalação/navegador**, sem conta e sem sincronização entre dispositivos.
- `shared_preferences` é ideal para um MVP e pequenos volumes; não oferece backups transacionais. Para produção com grande volume, considere SQLite (Drift) e sincronização com backend.
- Notificações push e integração com Google Calendar **não** estão implementadas nesta versão.
- Projeto-fonte criado sem SDK Flutter disponível neste ambiente; comandos de build, análise e testes devem ser executados localmente.
