<!-- Fichier généré automatiquement à partir de assets/legal/fr/. Ne pas modifier à la main : modifiez le contenu JSON, puis exécutez `dart run tool/export_legal_docs.dart`. -->

# Politique de confidentialité

**ValHub** · Version 1.2 · En vigueur à compter du : 04/10/2026

La présente Politique explique comment ValHub collecte, utilise, conserve et protège vos données personnelles, ainsi que les droits dont vous disposez sur ces données. Elle a été établie conformément au droit vietnamien relatif à la protection des données personnelles (décret n° 13/2023/NĐ-CP (Nghị định 13/2023/NĐ-CP)), en tenant compte également des règles dont vous pouvez bénéficier là où vous vivez, comme le RGPD, le RGPD britannique (UK GDPR), le CCPA/CPRA ou la LGPD (voir la section « Vos droits selon la loi du lieu où vous vivez »). ValHub s'adresse aux joueurs de VALORANT de tous les pays.

> En résumé : la plupart de vos données restent uniquement sur votre appareil. Vos données de connexion Riot sont conservées dans l'espace de stockage sécurisé du système d'exploitation et ne sont utilisées sur le serveur ValHub qu'après votre consentement explicite : pour vérifier votre Riot ID lors de la connexion à la Communauté et pour vérifier la possession d'un skin lorsque vous enregistrez un avis. Le jeton d'accès est détruit après chaque vérification. Le serveur ne conserve pas le PUUID (votre identifiant de joueur). ValHub n'affiche aucune publicité, n'utilise aucun outil d'analyse ou de suivi et ne vend pas vos données.

## 1. Responsable et exécutant du traitement des données

Nguyễn Đức Huy (« nous ») est la personne qui détermine les finalités et les moyens du traitement des données personnelles dans ValHub (responsable et exécutant du traitement des données personnelles). Ses coordonnées figurent dans la dernière section de la présente Politique.

## 2. Champ d'application

La présente Politique s'applique à l'application ValHub sur iOS et Android dans tous les pays, y compris aux fonctionnalités de la Communauté. Elle ne s'applique pas aux services de Riot Games, valorant-api.com, Apple, Google ou d'autres tiers. Chacun d'eux traite les données selon sa propre politique.

## 3. Données traitées sur votre appareil

Les données ci-dessous sont créées ou téléchargées lorsque vous utilisez l'application et sont conservées uniquement sur votre appareil. Nous ne recevons pas ces données.

- **Données de connexion Riot :** les données que Riot délivre à l'application après votre connexion sur la page officielle de Riot, à savoir le jeton d'accès (access token), le jeton de droits (entitlement token) et les cookies de connexion (des fichiers qui permettent à Riot de se souvenir que vous êtes connecté). Elles sont conservées dans le Trousseau (Keychain, iOS) ou dans un espace de stockage chiffré protégé par le Keystore (Android). ValHub ne voit jamais le mot de passe que vous saisissez sur la page de Riot.
- **Identifiants enregistrés (facultatif) :** si vous choisissez d'enregistrer votre nom d'utilisateur et votre mot de passe Riot pour vous reconnecter plus rapidement, ces informations restent uniquement dans l'espace de stockage sécurisé de l'appareil. Elles ne sont jamais inscrites dans un rapport de bug ni envoyées où que ce soit, sauf pour être saisies dans la page de connexion officielle de Riot lorsque vous le demandez.
- **Liste des comptes :** le Riot ID (nom#tag), l'identifiant de joueur (PUUID), la région, la plateforme, la carte de joueur, le niveau et le rang des comptes que vous ajoutez. L'application les utilise pour afficher la liste des comptes et passer de l'un à l'autre.
- **Données de jeu :** la boutique, le portefeuille, la collection, l'équipement, le Battle Pass, les contrats, l'historique des parties, le rang, la partie en cours, la liste d'amis, le statut en ligne et les messages de discussion. L'application les lit directement sur les serveurs de Riot au moyen de votre connexion Riot et peut en conserver une copie temporaire pour que vous puissiez les consulter hors connexion.
- **Wishlist et réglages :** la wishlist, les préférences d'affichage, les réglages de notification et de plateforme.
- **Données temporaires :** les noms et images des objets, agents et cartes provenant de valorant-api.com, ainsi que les images téléchargées, conservés temporairement pour que l'application fonctionne plus rapidement.
- **Rapports de bug :** un journal technique, sur l'appareil, de ce que l'application a fait (noms des requêtes envoyées, résultats et durées), utilisé pour trouver des bugs. Ce journal est filtré afin de ne contenir ni mot de passe, ni données de connexion Riot, ni identifiant de compte, et il ne quitte l'appareil que si vous choisissez vous-même « Envoyer un rapport de bug à ValHub » dans Paramètres > Avancé.

## 4. Données traitées sur le serveur de la Communauté

Le serveur de la Communauté est un serveur exploité par l'éditeur lui-même. Les données sont conservées dans la base de données et dans des fichiers sur les disques de ce serveur. Les connexions de l'Application vers ce serveur passent par le réseau de Cloudflare ; Cloudflare se contente de relayer les connexions. Ce n'est que lorsque vous utilisez les fonctionnalités de la Communauté que les données ci-dessous sont envoyées à ce serveur et y sont conservées :

- **Profil de la Communauté :** le Riot ID (nom et tag), la région, la carte de joueur, le rang et la langue de l'application, envoyés par l'Application. Ces informations sont publiques pour les autres utilisateurs de la Communauté.
- **Pays :** le pays de votre Compte Riot (fourni par Riot lors de la vérification, vous ne pouvez pas le modifier), utilisé pour afficher la Communauté par pays.
- **Identifiant utilisateur :** une empreinte (hachage) à sens unique (qui ne permet pas de retrouver le PUUID) générée à partir de votre PUUID. Le serveur ne conserve pas et ne renvoie pas votre PUUID.
- **Publications et commentaires :** le contenu des publications, les images que vous mettez en ligne, les informations de boutique ou de Marché nocturne que vous choisissez de partager, les commentaires, les « J'aime » et l'heure de publication.
- **Avis sur les skins :** le nombre d'étoiles, le texte de l'avis et les mentions « Utile » que vous attribuez aux avis des autres. Ces informations sont affichées publiquement avec votre Riot ID. Le serveur enregistre le moment où la possession du skin a été vérifiée ; les anciens avis non vérifiés sont signalés comme tels et ne sont pas pris en compte dans le classement.
- **Annonces de recherche de coéquipiers :** le code de groupe, le mode de jeu, la région, la fourchette de rangs, les rôles recherchés, l'exigence ou non d'un micro, la langue, la taille du groupe, le nombre de places libres, la note, le statut (ouvert, complet, en partie), le nombre de clics pour rejoindre le groupe, et le signal « toujours actif » que l'Application envoie régulièrement tant que l'annonce est ouverte. L'annonce expire automatiquement 30 minutes après le dernier signal. Chaque personne ne peut avoir qu'une seule annonce active.
- **Votes et « J'aime » :** les skins pour lesquels vous votez, les « J'aime » et leur date, utilisés pour classer les skins préférés.
- **Signalements d'infractions :** le contenu signalé, le motif et l'auteur du signalement (sous forme d'identifiant utilisateur), utilisés pour la modération.
- **Journaux d'accès du serveur :** le serveur enregistre le type, le chemin, le résultat et la durée de traitement de chaque requête afin d'assurer son fonctionnement et de trouver des bugs. L'adresse IP n'est utilisée que sous forme d'empreinte salée (une empreinte à sens unique à laquelle on ajoute une chaîne aléatoire) pour limiter le nombre de requêtes, et n'est jamais enregistrée sous une forme lisible. Cloudflare peut traiter l'adresse IP lorsqu'il relaie la connexion, conformément à sa propre politique.
- **Images mises en ligne :** les images que vous publiez sont enregistrées sous forme de fichiers sur les disques du serveur de la Communauté et peuvent être ouvertes via un lien public. La manière de supprimer les images est indiquée dans la section « Suppression des données ».
- **Sauvegardes :** le serveur est sauvegardé chaque jour ; les sauvegardes sont conservées 14 jours sur les serveurs de l'éditeur.

## 5. Jeton d'accès Riot et vérification du Riot ID

Vos données de connexion Riot (jeton d'accès, jeton de droits et cookies) ne sont utilisées sur le serveur ValHub que dans les cas de vérification décrits ci-dessous. Les cookies de connexion et le mot de passe ne sont pas envoyés au serveur de la Communauté :

- Après vous être connecté à Riot, vous devez lire et accepter avant de continuer à utiliser les fonctionnalités liées au compte. Votre choix est enregistré séparément pour chaque compte et chaque version de la politique. Si vous refusez, vous pouvez déconnecter ce compte. Le fait d'accepter n'envoie pas automatiquement de jeton Riot ; l'application n'envoie le jeton d'accès via HTTPS que lorsqu'elle se reconnecte à la Communauté ou lorsque vous choisissez vous-même d'enregistrer un avis sur un skin.
- Le serveur interroge Riot sur votre identité (PUUID et Riot ID). Lorsque vous enregistrez un avis, le serveur lit également auprès de Riot la possession du skin et vérifie que ce compte correspond à celui qui est connecté à la Communauté. Le jeton d'accès et le jeton de droits temporaires ne sont ni conservés ni inscrits dans les journaux ; le serveur les détruit après le traitement de la requête.
- Le serveur délivre à l'Application un jeton de connexion à la Communauté distinct, valable 30 jours. Ce jeton est conservé dans l'espace de stockage sécurisé de l'appareil et supprimé lorsque vous déconnectez le compte.
- Le serveur de la Communauté lit uniquement les informations d'identité et de possession des skins pour ces vérifications ; il n'achète aucun objet, ne change pas votre équipement et ne modifie pas votre Compte Riot.

## 6. Finalités du traitement

- Afficher les informations du compte, la boutique, la collection, les parties et les fonctionnalités que vous demandez.
- Envoyer des notifications directement sur l'appareil concernant la boutique, la wishlist et le Marché nocturne, si vous les activez.
- Faire fonctionner la Communauté : vérifier que l'auteur d'une publication est bien le titulaire du Riot ID, afficher les publications, commentaires, annonces de recherche de coéquipiers et le classement des skins.
- Assurer la sécurité : lutter contre le spam, les abus et la fraude ; modérer les contenus signalés ; limiter le nombre de requêtes sur une période donnée.
- Trouver et corriger les bugs lorsque vous choisissez d'envoyer un rapport de bug à ValHub.
- Respecter les obligations prévues par la loi.

Nous n'utilisons pas vos données à des fins publicitaires, nous n'établissons pas de profil comportemental et nous ne vendons, ne louons ni n'échangeons de données personnelles.

## 7. Bases juridiques

- **Votre consentement :** vous acceptez explicitement la présente Politique après votre connexion, et donnez un consentement distinct lorsque vous activez les notifications ou enregistrez vos identifiants. Vous pouvez retirer votre consentement à tout moment dans les Paramètres ; vous devrez alors accepter de nouveau ou vous déconnecter pour continuer à utiliser les fonctionnalités liées au compte.
- **Exécution d'un contrat :** le traitement nécessaire pour fournir les fonctionnalités que vous demandez conformément aux Conditions d'utilisation.
- **Intérêts légitimes :** protéger la Communauté contre le spam, les abus et la fraude, modérer les contenus signalés et assurer la sécurité du serveur, en limitant les données au strict nécessaire.
- **Obligation légale :** lorsque la loi l'exige, par exemple pour répondre à une demande légale d'une autorité publique compétente.

## 8. Partage des données

Nous ne partageons des données que dans les cas suivants :

- **Riot Games :** l'Application se connecte directement aux serveurs de Riot Games au moyen de votre connexion Riot pour lire les données du compte et effectuer les actions que vous demandez.
- **valorant-api.com :** l'Application télécharge des données publiques sur les objets ; elle n'envoie aucune information sur votre compte.
- **Fichiers publics :** l'Application peut télécharger l'état public des serveurs de Riot et le fichier de configuration générale de ValHub ; ces requêtes ne contiennent aucune donnée personnelle.
- **Cloudflare, Inc. :** fournit le réseau qui relaie les connexions vers le serveur de la Communauté. Cloudflare ne conserve pas nos données de la Communauté, mais peut traiter des données techniques telles que l'adresse IP conformément à sa propre politique.
- **Autres utilisateurs :** votre profil de la Communauté, vos publications, images, commentaires et annonces de recherche de coéquipiers sont visibles par les autres utilisateurs de ValHub. Les images publiées peuvent être ouvertes via un lien public.
- **Autorités publiques compétentes :** en cas de demande légale conforme à la loi applicable à l'éditeur.

## 9. Transferts de données hors frontières

Le serveur de la Communauté est exploité par l'éditeur lui-même. Les connexions vers ce serveur passent par le réseau mondial de Cloudflare, Inc., de sorte que les données peuvent transiter par plusieurs pays. Les données de la Communauté que vous publiez sont visibles par les utilisateurs de ValHub partout dans le monde. Lorsque vous utilisez l'Application, votre appareil se connecte également directement aux serveurs de Riot Games. Nous appliquons des mesures de protection appropriées et respectons les obligations relatives aux transferts transfrontaliers de données personnelles prévues par le droit vietnamien et, lorsque vous vous trouvez dans un lieu doté de règles équivalentes, par la loi du lieu où vous vivez.

## 10. Durée de conservation

- **Données sur l'appareil :** conservées jusqu'à ce que vous déconnectiez le compte concerné, effaciez les données temporaires ou désinstalliez l'Application. Les images en cache sont automatiquement renouvelées au bout d'environ 30 jours.
- **Annonces de recherche de coéquipiers :** expirent automatiquement et ne sont plus affichées 30 minutes après le dernier signal « toujours actif » ; les données expirées sont supprimées périodiquement.
- **Publications, avis, commentaires, votes :** conservés jusqu'à ce que vous les supprimiez, que nous les retirions pour infraction ou que vous demandiez la suppression de vos données de la Communauté.
- **Signalements d'infractions :** conservés au maximum 12 mois pour traiter les infractions et prévenir les abus, puis supprimés automatiquement par le serveur. Les signalements portant sur un contenu supprimé sont également supprimés, et les signalements que vous avez vous-même envoyés sont anonymisés lorsque vous supprimez vos données de la Communauté.
- **Journaux d'accès du serveur :** seule l'empreinte salée (de l'adresse IP) est conservée pour limiter le nombre de requêtes ; les journaux techniques ne sont conservés que le temps nécessaire à la recherche de bugs et à la sécurité.
- **Sauvegardes :** conservées 14 jours puis écrasées ; un contenu supprimé peut donc subsister dans une sauvegarde pendant 14 jours au maximum.
- **Jeton de connexion à la Communauté :** expire au bout de 30 jours, est supprimé de l'appareil lors de la déconnexion et est révoqué sur le serveur dès qu'une connexion réseau est disponible.

## 11. Suppression des données

### Sur l'appareil

- Déconnecter un compte dans les Paramètres supprime de l'appareil les données de connexion Riot (jeton d'accès et cookies), les identifiants enregistrés, le jeton de connexion à la Communauté, les données temporaires et les notifications programmées de ce compte. La wishlist, les configurations d'équipement et l'historique de RR, des parties et de la boutique sont également supprimés, sauf si vous choisissez, dans la fenêtre de confirmation, de conserver les données locales pour les retrouver lors d'une prochaine connexion.
- « Effacer les données temporaires » dans Paramètres > Avancé supprime les images, les données téléchargées pour la consultation hors connexion, les noms de joueurs recherchés et les rapports de bug enregistrés sur l'appareil. Votre propre historique est conservé.
- « Effacer les données locales » supprime l'historique, les configurations d'équipement et les données conservées des comptes déconnectés. La wishlist du compte connecté est conservée ; vous pouvez la vider vous-même dans Wishlist.
- Désinstaller l'Application supprime toutes les données de l'Application sur l'appareil.

### Sur le serveur de la Communauté

- Vous pouvez supprimer vous-même vos publications, avis, commentaires, annonces de recherche de coéquipiers et retirer vos votes directement dans l'Application.
- Pour supprimer toutes les données de la Communauté associées à votre Riot ID, allez dans Paramètres > « Vos données de la Communauté » > « Supprimer mes données de la Communauté ». Le serveur supprimera définitivement vos publications, commentaires, avis, « J'aime », votes, annonces de recherche de coéquipiers, images et votre compte de la Communauté. Cette action est irréversible. Vous pouvez également écrire à ndh0408@gmail.com en indiquant votre Riot ID ; nous pourrons vous demander de prouver que vous êtes le titulaire du compte et traiterons la demande dans un délai de 30 jours.
- Images : les fichiers image sont supprimés avec la publication ou le compte. Les images d'un contenu masqué à la suite de signalements ne sont plus accessibles publiquement et sont supprimées au bout de 30 jours ; les images mises en ligne mais non utilisées sont supprimées au bout de 24 heures. Lorsque vous mettez une image en ligne, le serveur en retire les informations de localisation et les données cachées (métadonnées EXIF).
- Un contenu supprimé peut subsister dans une sauvegarde pendant 14 jours au maximum avant d'être écrasé.
- Remarque : vous déconnecter de l'Application ne supprime pas automatiquement le contenu que vous avez publié sur le serveur de la Communauté.

## 12. Notifications et tâches en arrière-plan

ValHub utilise uniquement des notifications locales, c'est-à-dire des notifications créées par votre appareil lui-même. Nous n'exploitons pas de serveur de notifications push et ne collectons pas d'identifiant d'appareil. L'Application enregistre auprès du système d'exploitation une tâche périodique en arrière-plan, exécutée directement sur l'appareil, afin de maintenir votre connexion Riot valide et, si vous l'activez, de lire la boutique directement auprès de Riot pour vous prévenir lorsqu'un skin de votre wishlist ou le Marché nocturne est disponible. Vous pouvez désactiver les notifications dans les Paramètres de l'Application ou du système d'exploitation.

## 13. Traduction du contenu sur l'appareil

Lorsque vous choisissez de traduire un contenu de la Communauté, ValHub utilise l'outil de traduction ML Kit de Google, qui fonctionne sur l'appareil. Si le pack de langue nécessaire n'est pas encore installé, ValHub vous demande votre accord avant de le télécharger auprès de Google (environ 30 Mo par pack). Le téléchargement nécessite une connexion réseau, et Google peut recevoir des informations techniques sur la connexion, comme l'adresse IP, conformément à la politique de Google. Le contenu des publications est traduit sur l'appareil et n'est pas envoyé à Google pour être traduit. Vous pouvez ne pas utiliser cette fonctionnalité ; ValHub n'utilise ni chatbot ni service de génération de contenu par IA.

## 14. Analyse, publicité et suivi

ValHub n'intègre aucun outil d'analyse, outil de signalement automatique des plantages, publicité ou outil de suivi tiers. ValHub n'utilise pas d'identifiant publicitaire et ne vous suit pas d'une application ou d'un site web à l'autre. Si cela venait à changer, nous mettrions à jour la présente Politique et vous demanderions votre consentement lorsque la loi l'exige.

## 15. Sécurité des données

- Les informations secrètes (données de connexion Riot, identifiants enregistrés, jeton de connexion à la Communauté) sont conservées uniquement dans l'espace de stockage sécurisé du système d'exploitation (Keychain ou Keystore) et sont supprimées lors de la réinstallation de l'Application.
- Toutes les connexions réseau sont chiffrées (HTTPS/TLS).
- Les rapports de bug sont automatiquement filtrés pour en retirer les données de connexion Riot, les mots de passe et les identifiants de compte.
- Le serveur de la Communauté ne conserve qu'une empreinte à sens unique du PUUID ; il limite le nombre de requêtes (sur la base de l'empreinte salée de l'adresse IP) ; il ne vous permet de supprimer que votre propre contenu ; et il conserve les clés secrètes dans la configuration privée du serveur, hors du code source.
- Nous ne collectons que les données strictement nécessaires aux fonctionnalités.

Aucune mesure n'est sûre à 100 %. En cas de violation de données personnelles, nous en informerons les autorités compétentes et les utilisateurs concernés conformément à la loi.

## 16. Enfants

L'Application ne s'adresse pas aux enfants de moins de 13 ans. Là où la loi fixe un âge minimum plus élevé pour consentir soi-même au traitement des données (par exemple 16 ans dans certains pays de l'Union européenne), vous ne pouvez utiliser l'Application, et notamment les fonctionnalités de la Communauté, que si vous avez atteint cet âge ou avec le consentement et sous la supervision de l'un de vos parents ou de votre représentant légal. Si vous êtes parent et pensez que votre enfant a fourni des données à la Communauté sans ce consentement, veuillez nous contacter afin que nous supprimions ces données.

## 17. Vos droits

En vertu du droit vietnamien relatif à la protection des données personnelles (notamment le décret n° 13/2023/NĐ-CP), vous disposez des droits suivants :

- **Droit d'être informé :** être informé des traitements de vos données ;
- **Droit de consentir :** consentir ou non au traitement de vos données ;
- **Droit d'accès :** consulter, modifier ou demander la modification de vos données ;
- **Droit de retirer votre consentement :** retirer le consentement que vous avez donné ;
- **Droit à l'effacement :** demander la suppression de vos données ;
- **Droit à la limitation du traitement :** demander la limitation du traitement de vos données ;
- **Droit d'obtenir vos données :** demander que vos données vous soient fournies ;
- **Droit d'opposition :** vous opposer au traitement de vos données à des fins non souhaitées ;
- **Droit de réclamation et de réparation :** déposer une réclamation, une dénonciation, intenter une action en justice et demander réparation du préjudice conformément à la loi ;
- **Droit à l'autoprotection :** protéger vous-même vos données personnelles.

La plupart des données se trouvent sur votre appareil, et vous pouvez les consulter ou les supprimer vous-même directement dans l'Application. Pour les données présentes sur le serveur de la Communauté, envoyez votre demande à ndh0408@gmail.com. Nous traitons les demandes dans un délai de 30 jours et pouvons avoir besoin de vérifier votre identité au préalable. Vous pouvez également télécharger vous-même une copie de vos données de la Communauté (fichier JSON) dans Paramètres > « Vos données de la Communauté » > « Télécharger mes données », et supprimer vous-même ces données au même endroit.

## 18. Vos droits selon la loi du lieu où vous vivez

Selon l'endroit où vous vivez, la loi locale peut vous accorder des droits supplémentaires. Où que vous soyez, vous pouvez exercer les droits concrets ci-dessous en écrivant à ndh0408@gmail.com ; nous traitons les demandes dans un délai de 30 jours et ne vous traiterons pas de manière discriminatoire parce que vous avez exercé vos droits.

- **Accès :** savoir quelles données nous détenons à votre sujet et en recevoir une copie ;
- **Effacement :** demander la suppression des données de la Communauté associées à votre Riot ID (voir la section « Suppression des données ») ;
- **Rectification :** corriger des données inexactes (le profil de la Communauté est actualisé à partir de votre compte Riot à chaque connexion) ;
- **Portabilité des données :** recevoir vos données dans un format couramment utilisé ;
- **Opposition, limitation et retrait du consentement :** vous opposer au traitement ou en demander la limitation, et retirer votre consentement à tout moment ;
- **Réclamation :** déposer une réclamation auprès de l'autorité de protection des données compétente du lieu où vous vivez.

Quelques exemples de lois susceptibles de s'appliquer à vous :

- **RGPD / UK GDPR :** si vous vous trouvez dans l'Union européenne, dans l'Espace économique européen ou au Royaume-Uni : vous disposez des droits d'accès, de rectification, d'effacement, de limitation, de portabilité des données, d'opposition et de retrait du consentement, ainsi que du droit d'introduire une réclamation auprès de l'autorité de contrôle de la protection des données de votre pays de résidence. Les bases du traitement des données sont indiquées dans la section « Bases juridiques ».
- **CCPA / CPRA :** si vous résidez en Californie : vous avez le droit de savoir, de supprimer et de corriger des données, et de refuser la « vente » ou le « partage » de données. ValHub ne vend pas de données personnelles et ne les partage pas à des fins de publicité comportementale intercontextuelle.
- **LGPD :** si vous vous trouvez au Brésil : vous disposez des droits d'accès, de rectification, d'anonymisation, d'effacement, de portabilité des données et d'information sur le partage des données.
- **PIPL et lois similaires :** si vous vous trouvez en Chine continentale ou dans un lieu doté d'une loi similaire : vous avez le droit de savoir, de décider, de limiter, de refuser, d'accéder, de copier, de rectifier, de supprimer des données et de demander des explications sur le traitement.
- **Décret n° 13/2023/NĐ-CP :** si vous vous trouvez au Viêt Nam : les droits énoncés dans la section « Vos droits » ci-dessus.

Nous ne collectons pas plus de données que nécessaire et ne prenons aucune décision automatisée produisant des effets juridiques à votre égard. Si notre réponse ne vous satisfait pas, vous avez le droit d'introduire une réclamation auprès de l'autorité compétente du lieu où vous vivez.

## 19. Modification de la Politique

Nous pouvons mettre à jour la présente Politique lorsque l'Application ou la réglementation évolue. La version et la date d'entrée en vigueur figurent toujours en tête du document. En cas de modification importante de la manière dont les données sont traitées, nous vous en informerons dans l'Application et vous demanderons de nouveau votre consentement si nécessaire.

## 20. Contact

Pour toute question ou demande concernant la confidentialité et les données personnelles, veuillez contacter :

- **Responsable du traitement :** Nguyễn Đức Huy
- **E-mail :** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Tous droits réservés.
