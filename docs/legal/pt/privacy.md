<!-- Arquivo gerado automaticamente a partir de assets/legal/pt/. Não edite manualmente: edite o conteúdo JSON e depois execute `dart run tool/export_legal_docs.dart`. -->

# Política de Privacidade

**ValHub** · Versão 1.2 · Em vigor desde: 04/10/2026

Esta Política explica como o ValHub coleta, usa, armazena e protege os seus dados pessoais, bem como os direitos que você tem sobre esses dados. Ela foi elaborada com base na legislação vietnamita de proteção de dados pessoais (Decreto nº 13/2023/NĐ-CP (Nghị định 13/2023/NĐ-CP)) e também leva em conta as normas que possam beneficiar você no lugar onde vive, como o GDPR, o UK GDPR, a CCPA/CPRA ou a LGPD (veja a seção “Seus direitos segundo a lei do lugar onde você vive”). O ValHub é destinado a jogadores de VALORANT de todos os países.

> Resumo: a maior parte dos seus dados fica apenas no seu dispositivo. Os seus dados de login da Riot são guardados no armazenamento seguro do sistema operacional e só são usados no servidor do ValHub após o seu consentimento expresso: para verificar o seu Riot ID quando você se conecta à Comunidade e para verificar a posse de skins quando você salva uma avaliação. O token de acesso é descartado após cada verificação. O servidor não armazena o seu PUUID (o seu identificador de jogador). O ValHub não tem anúncios, não usa ferramentas de análise nem de rastreamento e não vende os seus dados.

## 1. Controlador e operador dos dados

Nguyễn Đức Huy (“nós”) é quem decide as finalidades e os meios do tratamento de dados pessoais no ValHub (controlador e operador de dados pessoais). As informações de contato estão na última seção desta Política.

## 2. Âmbito de aplicação

Esta Política se aplica ao aplicativo ValHub para iOS e Android em todos os países, incluindo os recursos da Comunidade. Ela não se aplica aos serviços da Riot Games, do valorant-api.com, da Apple, do Google ou de outros terceiros. Cada um deles trata dados de acordo com a sua própria política.

## 3. Dados tratados no seu dispositivo

Os dados abaixo são criados ou baixados quando você usa o aplicativo e ficam armazenados apenas no seu dispositivo. Nós não recebemos esses dados.

- **Dados de login da Riot:** dados que a Riot fornece ao aplicativo depois que você faz login na página oficial da Riot, incluindo o token de acesso (access token), o token de titularidade (entitlement token) e os cookies de login (arquivos que ajudam a Riot a lembrar que você está conectado). Eles são guardados no Keychain (iOS) ou em um armazenamento criptografado protegido pelo Keystore (Android). O ValHub nunca vê a senha que você digita na página da Riot.
- **Dados de login salvos (opcional):** se você optar por salvar o seu nome de usuário e a sua senha da Riot para entrar novamente mais rápido, essas informações ficam apenas no armazenamento seguro do dispositivo. Elas nunca são gravadas em relatórios de erros nem enviadas a lugar algum, exceto para serem preenchidas na página de login oficial da Riot quando você solicitar.
- **Lista de contas:** Riot ID (nome#tag), identificador de jogador (PUUID), região, plataforma, Cartão de Jogador, nível e ranque das contas que você adiciona. O aplicativo usa esses dados para exibir a lista de contas e alternar entre elas.
- **Dados do jogo:** loja, carteira, coleção, loadout, Passe de Batalha, contratos, histórico de partidas, ranque, partida atual, lista de amigos, status online e mensagens de chat. O aplicativo lê esses dados diretamente dos servidores da Riot usando o seu login da Riot e pode guardar uma cópia temporária para que você os veja sem conexão.
- **Wishlist e configurações:** wishlist, preferências de aparência, configurações de notificação e plataforma.
- **Dados temporários:** nomes e imagens de itens, agentes e mapas obtidos do valorant-api.com, além das imagens baixadas, armazenados temporariamente para que o aplicativo funcione mais rápido.
- **Relatórios de erros:** registro técnico no dispositivo do que o aplicativo fez (nomes das solicitações enviadas, resultados e horários), usado para encontrar erros. O registro é filtrado para não conter senhas, dados de login da Riot nem IDs de conta, e só sai do dispositivo quando você mesmo escolhe “Enviar relatório de erros ao ValHub” em Configurações > Avançado.

## 4. Dados tratados no servidor da Comunidade

O servidor da Comunidade é um servidor operado pelo próprio publicador. Os dados são armazenados no banco de dados e em arquivos no disco desse servidor. As conexões do Aplicativo com esse servidor passam pela rede da Cloudflare; a Cloudflare apenas encaminha as conexões. Somente quando você usa os recursos da Comunidade os dados abaixo são enviados e armazenados nesse servidor:

- **Perfil da Comunidade:** Riot ID (nome e tag), região, Cartão de Jogador, ranque e idioma do aplicativo, enviados pelo Aplicativo. Essas informações são públicas para os outros usuários da Comunidade.
- **País:** o país da sua Conta Riot (fornecido pela Riot durante a verificação; você não pode editá-lo), usado para exibir a Comunidade por país.
- **Código de usuário:** um hash unidirecional (a partir do qual não é possível obter o PUUID) gerado a partir do seu PUUID. O servidor não armazena nem devolve o seu PUUID.
- **Publicações e comentários:** conteúdo das publicações, imagens que você envia, informações da loja ou do Mercado Noturno que você escolhe compartilhar, comentários, curtidas e horário de publicação.
- **Avaliações de skins:** número de estrelas, texto das avaliações e os votos de “útil” que você dá às avaliações de outras pessoas. Essas informações são exibidas publicamente junto com o seu Riot ID. O servidor guarda o momento em que a posse da skin foi verificada; avaliações antigas ainda não verificadas são identificadas como tal e não contam para a pontuação do ranking.
- **Anúncios de grupo:** código do grupo, modo de jogo, região, limite de ranque, funções procuradas, se é preciso microfone, idioma, tamanho do grupo, vagas abertas, observações, status (aberto, cheio, jogando), número de toques no grupo e o sinal de “ainda ativo” que o Aplicativo envia periodicamente enquanto o anúncio está aberto. O anúncio expira automaticamente 30 minutos após o último sinal. Cada pessoa só pode ter um anúncio ativo.
- **Votos e curtidas:** as skins em que você vota, as curtidas e o momento em que isso foi feito, usados para montar o ranking das skins favoritas.
- **Denúncias:** conteúdo denunciado, motivo e autor da denúncia (na forma de código de usuário), usados para moderação.
- **Registros de acesso do servidor:** o servidor registra o tipo de solicitação, o caminho, o resultado e o tempo de processamento de cada solicitação para operar e encontrar erros. O endereço IP só é usado na forma de hash com salt (um hash unidirecional acrescido de uma sequência aleatória) para limitar o número de solicitações, e não é registrado em formato legível. A Cloudflare pode tratar o endereço IP ao encaminhar as conexões, de acordo com a sua própria política.
- **Imagens enviadas:** as imagens que você publica são armazenadas como arquivos no disco do servidor da Comunidade e podem ser abertas por meio de um link público. A forma de excluir imagens está descrita na seção “Exclusão de dados”.
- **Backup:** o servidor faz backup diariamente; os backups são mantidos por 14 dias no servidor do publicador.

## 5. Token de acesso da Riot e verificação do Riot ID

Os seus dados de login da Riot (token de acesso, token de titularidade e cookies) só são usados no servidor do ValHub nos casos de verificação descritos abaixo. Os cookies de login e a senha não são enviados ao servidor da Comunidade:

- Depois de fazer login na Riot, você precisa ler e escolher concordar antes de continuar usando os recursos de conta. A decisão é guardada separadamente para cada conta e para cada versão da política. Se não concordar, você pode sair dessa conta. Escolher concordar não envia automaticamente nenhum token da Riot; o aplicativo só envia o token de acesso via HTTPS ao se reconectar à Comunidade ou quando você, por iniciativa própria, salva uma avaliação de skin.
- O servidor consulta a Riot sobre a sua identidade (PUUID e Riot ID). Quando você salva uma avaliação, o servidor também lê na Riot a posse da skin e verifica se essa conta corresponde à pessoa conectada à Comunidade. O token de acesso e o token de titularidade temporários não são armazenados nem gravados em registros; o servidor os descarta depois de processar a solicitação.
- O servidor fornece ao Aplicativo um token de login da Comunidade próprio, válido por 30 dias. Esse token é guardado no armazenamento seguro do dispositivo e é excluído quando você sai da conta.
- O servidor da Comunidade apenas lê as informações de identificação e de posse de skins para essas verificações; ele não compra itens, não altera o loadout nem faz alterações na sua Conta Riot.

## 6. Finalidades do tratamento

- Exibir informações da conta, loja, coleção, partidas e os recursos que você solicita.
- Enviar notificações diretamente no dispositivo sobre a loja, a wishlist e o Mercado Noturno, se você as ativar.
- Operar a Comunidade: verificar que quem publica é o titular do Riot ID e exibir publicações, comentários, anúncios de grupo e o ranking de skins.
- Garantir a segurança: combater spam, abuso e fraude; moderar conteúdo denunciado; limitar o número de solicitações em determinado período.
- Encontrar e corrigir erros quando você, por iniciativa própria, envia um relatório de erros ao ValHub.
- Cumprir obrigações previstas em lei.

Não usamos os seus dados para publicidade, não criamos perfis comportamentais e não vendemos, alugamos nem trocamos dados pessoais.

## 7. Bases legais

- **Seu consentimento:** você escolhe concordar expressamente com esta Política após fazer login e dá consentimento separado ao ativar notificações ou salvar dados de login. Você pode revogar o consentimento a qualquer momento nas Configurações; nesse caso, precisará concordar novamente ou sair da conta para continuar usando os recursos de conta.
- **Execução de contrato:** tratamento necessário para fornecer os recursos que você solicita de acordo com os Termos de Uso.
- **Legítimo interesse:** proteger a Comunidade contra spam, abuso e fraude, moderar conteúdo denunciado e manter a segurança do servidor, com o mínimo de dados necessário.
- **Obrigação legal:** quando a lei exigir, por exemplo, para responder a solicitações legais de autoridades públicas competentes.

## 8. Compartilhamento de dados

Só compartilhamos dados nos seguintes casos:

- **Riot Games:** o Aplicativo se conecta diretamente aos servidores da Riot Games usando o seu login da Riot para ler os dados da conta e realizar as ações que você solicita.
- **valorant-api.com:** o Aplicativo baixa dados públicos sobre itens; ele não envia informações da sua conta.
- **Arquivos públicos:** o Aplicativo pode baixar o status público dos servidores da Riot e o arquivo de configuração geral do ValHub; essas solicitações não incluem dados pessoais.
- **Cloudflare, Inc.:** fornece a rede que encaminha as conexões ao servidor da Comunidade. A Cloudflare não armazena os nossos dados da Comunidade, mas pode tratar dados técnicos, como o endereço IP, de acordo com a sua própria política.
- **Outros usuários:** o seu perfil da Comunidade, publicações, imagens, comentários e anúncios de grupo ficam visíveis para outros usuários do ValHub. As imagens publicadas podem ser abertas por meio de um link público.
- **Autoridades públicas competentes:** quando houver solicitação legal nos termos da legislação aplicável ao publicador.

## 9. Transferência internacional de dados

O servidor da Comunidade é operado pelo próprio publicador. As conexões com esse servidor passam pela rede global da Cloudflare, Inc., por isso os dados podem passar por vários países. Os dados que você publica na Comunidade ficam visíveis para usuários do ValHub em qualquer lugar. Quando você usa o Aplicativo, o seu dispositivo também se conecta diretamente aos servidores da Riot Games. Adotamos salvaguardas adequadas e cumprimos as obrigações relativas à transferência internacional de dados pessoais nos termos da legislação vietnamita e, quando você estiver em um lugar com normas equivalentes, da lei do lugar onde você vive.

## 10. Prazo de armazenamento

- **Dados no dispositivo:** armazenados até você sair da conta correspondente, limpar os dados temporários ou desinstalar o Aplicativo. As imagens armazenadas temporariamente são atualizadas automaticamente após cerca de 30 dias.
- **Anúncios de grupo:** expiram automaticamente e deixam de ser exibidos 30 minutos após o último sinal de “ainda ativo”; os dados expirados são excluídos periodicamente.
- **Publicações, avaliações, comentários e votos:** armazenados até você excluí-los, até os removermos por violação ou até você solicitar a exclusão dos seus dados da Comunidade.
- **Denúncias:** mantidas por no máximo 12 meses para tratar violações e prevenir abusos e, depois disso, o servidor as exclui automaticamente. Denúncias sobre conteúdo já excluído também são excluídas, e as denúncias que você mesmo enviou são anonimizadas quando você exclui os seus dados da Comunidade.
- **Registros de acesso do servidor:** apenas o hash com salt (do endereço IP) é mantido para limitar o número de solicitações; os registros técnicos são mantidos somente pelo tempo necessário para encontrar erros e garantir a segurança.
- **Backups:** mantidos por 14 dias e depois sobrescritos; por isso, o conteúdo excluído pode permanecer nos backups por até 14 dias.
- **Token de login da Comunidade:** expira após 30 dias, é excluído do dispositivo quando você sai da conta e é revogado no servidor quando houver conexão de rede.

## 11. Exclusão de dados

### No dispositivo

- Sair de uma conta nas Configurações exclui do dispositivo os dados de login da Riot (token de acesso e cookies), os dados de login salvos, o token de login da Comunidade, os dados temporários e as notificações agendadas dessa conta. A wishlist, os loadouts salvos e o histórico de RR, de partidas e da loja também são excluídos, a menos que você escolha manter os dados locais na caixa de confirmação para usá-los ao entrar novamente.
- “Limpar dados temporários”, em Configurações > Avançado, exclui imagens, dados baixados para visualização sem conexão, nomes de jogadores pesquisados e relatórios de erros gravados no dispositivo. O seu histórico pessoal é mantido.
- “Apagar dados locais” exclui o histórico, os loadouts salvos e os dados mantidos das contas desconectadas. A wishlist da conta conectada permanece; você mesmo pode excluí-la em Wishlist.
- Desinstalar o Aplicativo exclui todos os dados do Aplicativo no dispositivo.

### No servidor da Comunidade

- Você mesmo pode excluir publicações, avaliações, comentários e anúncios de grupo e retirar os seus votos diretamente no Aplicativo.
- Para excluir todos os dados da Comunidade vinculados ao seu Riot ID, acesse Configurações > “Seus dados da Comunidade” > “Excluir meus dados da Comunidade”. O servidor excluirá permanentemente as suas publicações, comentários, avaliações, curtidas, votos, anúncios de grupo, imagens e a sua conta da Comunidade. Essa ação não pode ser desfeita. Você também pode enviar um e-mail para ndh0408@gmail.com informando o seu Riot ID; podemos pedir que você comprove ser o titular da conta e atenderemos a solicitação em até 30 dias.
- Imagens: os arquivos de imagem são excluídos junto com a publicação ou a conta. As imagens de conteúdo ocultado por denúncia deixam de ser acessíveis publicamente e são excluídas após 30 dias; imagens enviadas mas não utilizadas são excluídas após 24 horas. Quando você envia uma imagem, o servidor remove as informações de localização e os dados ocultos da imagem (metadados EXIF).
- O conteúdo excluído pode permanecer nos backups por até 14 dias antes de ser sobrescrito.
- Observação: sair do Aplicativo não exclui automaticamente o conteúdo que você publicou no servidor da Comunidade.

## 12. Notificações e tarefas em segundo plano

O ValHub usa apenas notificações locais, ou seja, notificações geradas pelo próprio dispositivo. Não operamos um servidor de notificações push e não coletamos tokens de dispositivo. O Aplicativo registra no sistema operacional uma tarefa periódica em segundo plano, executada no próprio dispositivo, para manter o seu login da Riot válido e, se você ativar, ler a loja diretamente da Riot para avisar sobre skins da wishlist ou do Mercado Noturno. Você pode desativar as notificações nas Configurações do Aplicativo ou do sistema operacional.

## 13. Tradução de conteúdo no dispositivo

Quando você escolhe traduzir conteúdo da Comunidade, o ValHub usa a ferramenta de tradução ML Kit do Google, executada no dispositivo. Se o pacote de idioma necessário ainda não estiver instalado, o ValHub pergunta a você antes de baixá-lo do Google (cerca de 30 MB por pacote). O download exige conexão de rede, e o Google pode receber informações técnicas da conexão, como o endereço IP, de acordo com a política do Google. O conteúdo das publicações é traduzido no dispositivo e não é enviado ao Google para tradução. Você pode optar por não usar esse recurso; o ValHub não usa chatbots nem serviços de geração de conteúdo por IA.

## 14. Análise, publicidade e rastreamento

O ValHub não integra ferramentas de análise, ferramentas de relatório automático de falhas, publicidade nem ferramentas de rastreamento de terceiros. O ValHub não usa identificadores de publicidade e não rastreia você entre aplicativos ou sites. Se isso mudar no futuro, atualizaremos esta Política e pediremos o seu consentimento quando a lei exigir.

## 15. Segurança dos dados

- As informações sigilosas (dados de login da Riot, dados de login salvos, token de login da Comunidade) são guardadas apenas no armazenamento seguro do sistema operacional (Keychain ou Keystore) e são excluídas quando o Aplicativo é reinstalado.
- Todas as conexões de rede são criptografadas (HTTPS/TLS).
- Os relatórios de erros são filtrados automaticamente para remover dados de login da Riot, senhas e IDs de conta.
- O servidor da Comunidade armazena apenas o hash unidirecional do PUUID; limita o número de solicitações (com base no hash com salt do endereço IP); só permite que você exclua o seu próprio conteúdo; e guarda as chaves secretas na configuração privada do servidor, e não no código-fonte.
- Coletamos apenas o mínimo de dados necessário para cada recurso.

Nenhuma medida é totalmente segura. Se ocorrer um incidente de segurança envolvendo dados pessoais, notificaremos as autoridades competentes e os usuários afetados conforme exigido pela lei.

## 16. Crianças

O Aplicativo não é destinado a crianças menores de 13 anos. Nos lugares em que a lei estabelece uma idade mínima mais alta para consentir por conta própria com o tratamento de dados (por exemplo, 16 anos em alguns países da União Europeia), você só pode usar o Aplicativo, especialmente os recursos da Comunidade, quando tiver atingido essa idade ou com o consentimento e a supervisão de pai, mãe ou responsável legal. Se você é pai, mãe ou responsável e acredita que o seu filho forneceu dados à Comunidade sem consentimento, entre em contato para que possamos excluir esses dados.

## 17. Seus direitos

De acordo com a legislação vietnamita de proteção de dados pessoais (incluindo o Decreto nº 13/2023/NĐ-CP), você tem os seguintes direitos:

- **Direito à informação:** ser informado sobre o tratamento dos seus dados;
- **Direito de consentir:** consentir ou não com o tratamento dos seus dados;
- **Direito de acesso:** ver, corrigir ou solicitar a correção dos seus dados;
- **Direito de revogar o consentimento:** revogar o consentimento dado;
- **Direito à exclusão dos dados:** solicitar a exclusão dos seus dados;
- **Direito à restrição do tratamento:** solicitar a restrição do tratamento dos seus dados;
- **Direito ao fornecimento dos dados:** solicitar o fornecimento dos seus dados;
- **Direito de oposição ao tratamento:** opor-se ao tratamento dos seus dados para finalidades indesejadas;
- **Direito de reclamar e de pedir indenização:** apresentar reclamações e denúncias, ajuizar ações e pedir indenização por danos nos termos da lei;
- **Direito à autoproteção:** proteger por conta própria os seus dados pessoais.

A maior parte dos dados fica no seu dispositivo, e você mesmo pode vê-los ou excluí-los diretamente no Aplicativo. Para os dados no servidor da Comunidade, envie a sua solicitação para ndh0408@gmail.com. Atendemos as solicitações em até 30 dias e podemos precisar confirmar a sua identidade antes de atendê-las. Você também pode baixar por conta própria uma cópia dos seus dados da Comunidade (arquivo JSON) em Configurações > “Seus dados da Comunidade” > “Baixar meus dados” e excluir esses dados ali mesmo.

## 18. Seus direitos segundo a lei do lugar onde você vive

Dependendo de onde você vive, a legislação local pode conceder direitos adicionais. Esteja onde estiver, você pode exercer os direitos práticos abaixo enviando um e-mail para ndh0408@gmail.com; atendemos as solicitações em até 30 dias e não discriminamos você por exercer os seus direitos.

- **Acesso:** saber quais dados mantemos sobre você e receber uma cópia;
- **Exclusão:** solicitar a exclusão dos dados da Comunidade vinculados ao seu Riot ID (veja a seção “Exclusão de dados”);
- **Correção:** corrigir dados incorretos (o perfil da Comunidade é atualizado a partir da conta Riot sempre que você se conecta);
- **Portabilidade dos dados:** receber os seus dados em um formato de uso comum;
- **Oposição, restrição e revogação do consentimento:** opor-se ao tratamento ou solicitar a sua restrição, e revogar o consentimento a qualquer momento;
- **Reclamação:** apresentar reclamação à autoridade de proteção de dados competente do lugar onde você vive.

Alguns exemplos de leis que podem se aplicar a você:

- **GDPR / UK GDPR:** se você está na União Europeia, no Espaço Econômico Europeu ou no Reino Unido: você tem os direitos de acesso, retificação, apagamento, restrição, portabilidade dos dados, oposição e revogação do consentimento, além do direito de apresentar reclamação à autoridade de controle de proteção de dados do país onde vive. As bases para o tratamento de dados estão descritas na seção “Bases legais”.
- **CCPA / CPRA:** se você é residente da Califórnia: você tem o direito de saber, excluir e corrigir dados e de recusar a “venda” ou o “compartilhamento” de dados. O ValHub não vende dados pessoais e não os compartilha para publicidade comportamental entre contextos.
- **LGPD:** se você está no Brasil: você tem os direitos de acesso, correção, anonimização, eliminação, portabilidade dos dados e informação sobre o compartilhamento de dados.
- **PIPL e leis semelhantes:** se você está na China continental ou em um lugar com leis semelhantes: você tem o direito de saber, decidir, restringir, recusar, acessar, copiar, corrigir e excluir dados e de solicitar explicações sobre o tratamento.
- **Decreto nº 13/2023/NĐ-CP:** se você está no Vietnã: os direitos descritos na seção “Seus direitos” acima.

Não coletamos mais dados do que o necessário e não tomamos decisões automatizadas que produzam efeitos jurídicos para você. Se não estiver satisfeito com a nossa resposta, você tem o direito de apresentar reclamação à autoridade competente do lugar onde vive.

## 19. Alterações desta Política

Podemos atualizar esta Política quando o Aplicativo ou a legislação mudarem. A versão e a data de vigência sempre aparecem no início do documento. Em caso de mudanças importantes na forma de tratar os dados, avisaremos no Aplicativo e pediremos novamente o seu consentimento quando necessário.

## 20. Contato

Para qualquer dúvida ou solicitação sobre privacidade e dados pessoais, entre em contato:

- **Controlador dos dados:** Nguyễn Đức Huy
- **E-mail:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Todos os direitos reservados.
