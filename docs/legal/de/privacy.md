<!-- Automatisch generierte Datei aus assets/legal/de/. Nicht von Hand bearbeiten: Bearbeite den JSON-Inhalt und führe dann `dart run tool/export_legal_docs.dart` aus. -->

# Datenschutzerklärung

**ValHub** · Version 1.2 · Gültig ab: 04/10/2026

Diese Datenschutzerklärung erläutert, wie ValHub deine personenbezogenen Daten erhebt, verwendet, speichert und schützt, und welche Rechte du in Bezug auf diese Daten hast. Sie beruht auf dem vietnamesischen Recht zum Schutz personenbezogener Daten (Dekret Nr. 13/2023/NĐ-CP (Nghị định 13/2023/NĐ-CP)) und berücksichtigt zugleich Vorschriften, die an deinem Wohnort zu deinen Gunsten gelten können, etwa die DSGVO, die UK GDPR, den CCPA/CPRA oder das LGPD (siehe Abschnitt „Deine Rechte nach dem Recht deines Wohnorts“). ValHub richtet sich an VALORANT-Spieler in allen Ländern.

> Kurzfassung: Der Großteil deiner Daten bleibt ausschließlich auf deinem Gerät. Deine Riot-Anmeldedaten werden im sicheren Speicher des Betriebssystems gespeichert und auf dem ValHub-Server nur nach deiner ausdrücklichen Einwilligung verwendet: um deine Riot ID beim Verbinden mit der Community zu bestätigen und um deinen Skin-Besitz zu prüfen, wenn du eine Bewertung speicherst. Das Zugriffstoken wird nach jeder Bestätigung verworfen. Der Server speichert deine PUUID (deine Spielerkennung) nicht. ValHub enthält keine Werbung, verwendet keine Analyse- oder Tracking-Tools und verkauft deine Daten nicht.

## 1. Verantwortlicher und Verarbeiter

Nguyễn Đức Huy („wir“) entscheidet über die Zwecke und Mittel der Verarbeitung personenbezogener Daten in ValHub (Verantwortlicher und Verarbeiter personenbezogener Daten). Die Kontaktdaten findest du im letzten Abschnitt dieser Datenschutzerklärung.

## 2. Geltungsbereich

Diese Datenschutzerklärung gilt für die ValHub-App unter iOS und Android in allen Ländern, einschließlich der Community-Funktionen. Sie gilt nicht für die Dienste von Riot Games, valorant-api.com, Apple, Google oder anderen Dritten. Jeder von ihnen verarbeitet Daten nach seinen eigenen Richtlinien.

## 3. Auf deinem Gerät verarbeitete Daten

Die folgenden Daten werden bei der Nutzung der App erzeugt oder heruntergeladen und nur auf deinem Gerät gespeichert. Wir erhalten diese Daten nicht.

- **Riot-Anmeldedaten:** Daten, die Riot der App ausstellt, nachdem du dich auf der offiziellen Seite von Riot angemeldet hast, darunter das Zugriffstoken (Access Token), das Berechtigungstoken (Entitlement Token) und Anmelde-Cookies (Dateien, mit denen sich Riot merkt, dass du angemeldet bist). Sie werden im Schlüsselbund (Keychain, iOS) oder in einem verschlüsselten, durch den Keystore geschützten Speicher (Android) abgelegt. ValHub sieht niemals das Passwort, das du auf der Seite von Riot eingibst.
- **Gespeicherte Anmeldedaten (optional):** Wenn du selbst entscheidest, deinen Riot-Benutzernamen und dein Passwort zu speichern, um dich schneller erneut anzumelden, bleiben diese Informationen nur im sicheren Speicher auf deinem Gerät. Sie werden niemals in Fehlerberichte geschrieben oder irgendwohin gesendet, außer dass sie auf deinen Wunsch in die offizielle Anmeldeseite von Riot eingetragen werden.
- **Kontoliste:** Riot ID (Name#Tag), Spielerkennung (PUUID), Region, Plattform, Spielerkarte, Level und Rang der Konten, die du hinzufügst. Die App verwendet sie, um die Kontoliste anzuzeigen und zwischen Konten zu wechseln.
- **Spieldaten:** Shop, Guthaben, Sammlung, Loadout, Battle Pass, Verträge, Matchverlauf, Rang, aktuelles Match, Freundesliste, Online-Status und Chatnachrichten. Die App liest diese mit deiner Riot-Anmeldung direkt von den Servern von Riot und kann eine temporäre Kopie speichern, damit du sie offline ansehen kannst.
- **Wishlist und Einstellungen:** Wishlist, Darstellungseinstellungen, Benachrichtigungseinstellungen und Plattform.
- **Temporäre Daten:** Namen und Bilder von Gegenständen, Agenten und Karten von valorant-api.com sowie heruntergeladene Bilder, die vorübergehend gespeichert werden, damit die App schneller läuft.
- **Fehlerberichte:** ein technisches Protokoll auf dem Gerät darüber, was die App getan hat (Namen gesendeter Anfragen, Ergebnisse und Zeitpunkte), das zur Fehlersuche dient. Das Protokoll wird so gefiltert, dass es keine Passwörter, Riot-Anmeldedaten oder Konto-IDs enthält, und verlässt dein Gerät nur, wenn du selbst unter Einstellungen > Erweitert „Fehlerbericht an ValHub senden“ wählst.

## 4. Auf dem Community-Server verarbeitete Daten

Der Community-Server ist ein vom Herausgeber selbst betriebener Server. Die Daten werden in der Datenbank und in Dateien auf dem Datenträger dieses Servers gespeichert. Verbindungen von der App zu diesem Server laufen über das Netzwerk von Cloudflare; Cloudflare leitet die Verbindungen lediglich weiter. Nur wenn du die Community-Funktionen nutzt, werden die folgenden Daten an diesen Server gesendet und dort gespeichert:

- **Community-Profil:** Riot ID (Name und Tag), Region, Spielerkarte, Rang und App-Sprache, von der App übermittelt. Diese Informationen sind für andere Nutzer in der Community öffentlich sichtbar.
- **Land:** das Land deines Riot-Kontos (von Riot bei der Bestätigung bereitgestellt; du kannst es nicht ändern), das verwendet wird, um die Community nach Ländern anzuzeigen.
- **Nutzerkennung:** ein aus deiner PUUID erzeugter Einweg-Hash (aus dem sich die PUUID nicht zurückberechnen lässt). Der Server speichert deine PUUID nicht und gibt sie nicht zurück.
- **Beiträge und Kommentare:** Inhalt deiner Beiträge, von dir hochgeladene Bilder, Shop- oder Nachtmarkt-Informationen, die du teilen möchtest, Kommentare, Likes und Zeitpunkte der Veröffentlichung.
- **Skin-Bewertungen:** Sternebewertungen, Bewertungstexte und deine „Hilfreich“-Stimmen für Bewertungen anderer. Diese Informationen werden zusammen mit deiner Riot ID öffentlich angezeigt. Der Server speichert den Zeitpunkt der Prüfung des Skin-Besitzes; ältere, nicht bestätigte Bewertungen werden deutlich gekennzeichnet und fließen nicht in die Ranglistenwertung ein.
- **Mitspielersuchen:** Gruppencode, Spielmodus, Region, Rangbegrenzung, gesuchte Rollen, ob ein Mikrofon erforderlich ist, Sprache, Gruppengröße, Anzahl freier Plätze, Notizen, Status (offen, voll, im Spiel), Anzahl der Tipps auf die Gruppe sowie das „Noch aktiv“-Signal, das die App regelmäßig sendet, solange die Mitspielersuche geöffnet ist. Eine Mitspielersuche läuft 30 Minuten nach dem letzten Signal automatisch ab. Jede Person kann nur eine aktive Mitspielersuche haben.
- **Stimmen und Likes:** die Skins, für die du abstimmst, deine Likes und deren Zeitpunkte, die verwendet werden, um die beliebtesten Skins zu ranken.
- **Meldungen von Verstößen:** der gemeldete Inhalt, der Grund und die meldende Person (als Nutzerkennung), zur Moderation verwendet.
- **Zugriffsprotokolle des Servers:** Der Server protokolliert für jede Anfrage Art, Pfad, Ergebnis und Bearbeitungsdauer, um den Betrieb sicherzustellen und Fehler zu finden. IP-Adressen werden nur als gesalzener Hash (ein Einweg-Hash, dem eine zufällige Zeichenfolge hinzugefügt wird) verwendet, um die Anfragehäufigkeit zu begrenzen, und nicht in lesbarer Form protokolliert. Cloudflare kann beim Weiterleiten von Verbindungen IP-Adressen nach seinen eigenen Richtlinien verarbeiten.
- **Hochgeladene Bilder:** Von dir gepostete Bilder werden als Dateien auf dem Datenträger des Community-Servers gespeichert und können über einen öffentlichen Link geöffnet werden. Wie du Bilder löschen kannst, ist im Abschnitt „Löschen von Daten“ beschrieben.
- **Sicherungen:** Der Server wird täglich gesichert; die Sicherungskopien werden 14 Tage lang auf dem Server des Herausgebers aufbewahrt.

## 5. Riot-Zugriffstoken und Bestätigung der Riot ID

Deine Riot-Anmeldedaten (Zugriffstoken, Berechtigungstoken und Cookies) werden auf dem ValHub-Server nur in den unten beschriebenen Bestätigungsfällen verwendet. Anmelde-Cookies und Passwörter werden nicht an den Community-Server gesendet:

- Nach der Anmeldung bei Riot musst du die Informationen lesen und deine Zustimmung erklären, bevor du die Kontofunktionen weiter nutzen kannst. Deine Entscheidung wird für jedes Konto und jede Version der Datenschutzerklärung gesondert gespeichert. Wenn du nicht zustimmst, kannst du dich von diesem Konto abmelden. Die Zustimmung allein sendet kein Riot-Token; die App sendet das Zugriffstoken über HTTPS nur, wenn sie sich erneut mit der Community verbindet oder wenn du aktiv eine Skin-Bewertung speicherst.
- Der Server fragt bei Riot deine Identität ab (PUUID und Riot ID). Wenn du eine Bewertung speicherst, liest der Server zusätzlich deinen Skin-Besitz bei Riot aus und prüft, ob dieses Konto mit der in der Community angemeldeten Person übereinstimmt. Das temporäre Zugriffstoken und Berechtigungstoken werden weder gespeichert noch protokolliert; der Server verwirft sie nach Bearbeitung der Anfrage.
- Der Server stellt der App ein eigenes Community-Anmeldetoken aus, das 30 Tage gültig ist. Dieses Token wird im sicheren Speicher auf deinem Gerät abgelegt und gelöscht, wenn du dich von dem Konto abmeldest.
- Der Community-Server liest für diese Bestätigungen nur Identitätsinformationen und den Skin-Besitz aus; er kauft keine Gegenstände, ändert kein Loadout und nimmt keine Änderungen an deinem Riot-Konto vor.

## 6. Zwecke der Verarbeitung

- Anzeige von Kontoinformationen, Shop, Sammlung, Matches und den von dir angeforderten Funktionen.
- Versand von Benachrichtigungen direkt auf dem Gerät zu Shop, Wishlist und Nachtmarkt, wenn du sie aktivierst.
- Betrieb der Community: Bestätigung, dass die postende Person Inhaber der Riot ID ist, sowie Anzeige von Beiträgen, Kommentaren, Mitspielersuchen und Skin-Ranglisten.
- Gewährleistung der Sicherheit: Verhinderung von Spam, Missbrauch und Betrug; Moderation gemeldeter Inhalte; Begrenzung der Anzahl von Anfragen innerhalb eines bestimmten Zeitraums.
- Finden und Beheben von Fehlern, wenn du ValHub aktiv einen Fehlerbericht sendest.
- Erfüllung gesetzlicher Pflichten.

Wir verwenden deine Daten nicht für Werbung, erstellen keine Verhaltensprofile und verkaufen, vermieten oder tauschen keine personenbezogenen Daten.

## 7. Rechtsgrundlagen

- **Deine Einwilligung:** Du stimmst dieser Datenschutzerklärung nach der Anmeldung ausdrücklich zu und erteilst eine gesonderte Einwilligung, wenn du Benachrichtigungen aktivierst oder Anmeldedaten speicherst. Du kannst deine Einwilligung jederzeit in den Einstellungen widerrufen; um die Kontofunktionen weiter zu nutzen, musst du dann erneut zustimmen oder dich abmelden.
- **Vertragserfüllung:** Verarbeitung, die erforderlich ist, um die von dir angeforderten Funktionen gemäß den Nutzungsbedingungen bereitzustellen.
- **Berechtigte Interessen:** Schutz der Community vor Spam, Missbrauch und Betrug, Moderation gemeldeter Inhalte und Gewährleistung der Serversicherheit, mit dem dafür erforderlichen Mindestmaß an Daten.
- **Rechtliche Verpflichtung:** wenn das Gesetz es verlangt, zum Beispiel zur Beantwortung rechtmäßiger Anfragen zuständiger staatlicher Behörden.

## 8. Weitergabe von Daten

Wir geben Daten nur in den folgenden Fällen weiter:

- **Riot Games:** Die App verbindet sich mit deiner Riot-Anmeldung direkt mit den Servern von Riot Games, um Kontodaten zu lesen und die von dir angeforderten Aktionen auszuführen.
- **valorant-api.com:** Die App lädt öffentliche Daten zu Gegenständen herunter; sie sendet keine Kontoinformationen von dir.
- **Öffentliche Dateien:** Die App kann den öffentlichen Serverstatus von Riot und die allgemeine Konfigurationsdatei von ValHub herunterladen; diese Anfragen enthalten keine personenbezogenen Daten.
- **Cloudflare, Inc.:** stellt das Netzwerk bereit, das Verbindungen zum Community-Server weiterleitet. Cloudflare speichert unsere Community-Daten nicht, kann aber technische Daten wie IP-Adressen nach seinen eigenen Richtlinien verarbeiten.
- **Andere Nutzer:** Dein Community-Profil, deine Beiträge, Bilder, Kommentare und Mitspielersuchen sind für andere ValHub-Nutzer sichtbar. Gepostete Bilder können über einen öffentlichen Link geöffnet werden.
- **Zuständige staatliche Behörden:** bei einer rechtmäßigen Anfrage nach den Gesetzen, die für den Herausgeber gelten.

## 9. Grenzüberschreitende Datenübermittlung

Der Community-Server wird vom Herausgeber selbst betrieben. Verbindungen zu diesem Server laufen über das globale Netzwerk von Cloudflare, Inc., sodass Daten mehrere Länder durchlaufen können. Von dir gepostete Community-Daten sind für ValHub-Nutzer überall sichtbar. Wenn du die App nutzt, verbindet sich dein Gerät außerdem direkt mit den Servern von Riot Games. Wir wenden angemessene Schutzmaßnahmen an und erfüllen die Pflichten im Zusammenhang mit der grenzüberschreitenden Übermittlung personenbezogener Daten nach vietnamesischem Recht und, wenn an deinem Wohnort entsprechende Vorschriften gelten, nach dem Recht deines Wohnorts.

## 10. Speicherdauer

- **Daten auf dem Gerät:** werden gespeichert, bis du dich vom jeweiligen Konto abmeldest, die temporären Daten löschst oder die App deinstallierst. Vorübergehend gespeicherte Bilder werden nach etwa 30 Tagen automatisch erneuert.
- **Mitspielersuchen:** laufen 30 Minuten nach dem letzten „Noch aktiv“-Signal automatisch ab und werden nicht mehr angezeigt; abgelaufene Daten werden regelmäßig gelöscht.
- **Beiträge, Bewertungen, Kommentare, Stimmen:** werden gespeichert, bis du sie löschst, wir sie wegen eines Verstoßes entfernen oder du die Löschung deiner Community-Daten verlangst.
- **Meldungen von Verstößen:** werden höchstens 12 Monate aufbewahrt, um Verstöße zu bearbeiten und Missbrauch vorzubeugen, und dann vom Server automatisch gelöscht. Meldungen zu gelöschten Inhalten werden ebenfalls gelöscht, und von dir selbst gesendete Meldungen werden anonymisiert, wenn du deine Community-Daten löschst.
- **Zugriffsprotokolle des Servers:** Es wird nur der gesalzene Hash (der IP-Adresse) aufbewahrt, um die Anfragehäufigkeit zu begrenzen; technische Protokolle werden nur so lange aufbewahrt, wie es für Fehlersuche und Sicherheit erforderlich ist.
- **Sicherungskopien:** werden 14 Tage aufbewahrt und dann überschrieben; gelöschte Inhalte können daher noch bis zu 14 Tage in Sicherungskopien enthalten sein.
- **Community-Anmeldetoken:** läuft nach 30 Tagen ab, wird bei der Abmeldung vom Gerät gelöscht und auf dem Server widerrufen, sobald eine Netzwerkverbindung besteht.

## 11. Löschen von Daten

### Auf dem Gerät

- Wenn du dich in den Einstellungen von einem Konto abmeldest, werden die Riot-Anmeldedaten (Zugriffstoken und Cookies), gespeicherten Anmeldedaten, das Community-Anmeldetoken, die temporären Daten und die geplanten Benachrichtigungen dieses Kontos vom Gerät gelöscht. Wishlist, Loadout-Konfigurationen sowie RR-, Match- und Shop-Verlauf werden ebenfalls gelöscht, es sei denn, du entscheidest dich im Bestätigungsdialog, die lokalen Daten für eine erneute Anmeldung zu behalten.
- „Temporäre Daten löschen“ unter Einstellungen > Erweitert löscht Bilder, für die Offline-Ansicht heruntergeladene Daten, nachgeschlagene Spielernamen und auf dem Gerät gespeicherte Fehlerberichte. Dein eigener Verlauf bleibt erhalten.
- „Lokale Daten löschen“ löscht Verlauf, Loadout-Konfigurationen und aufbewahrte Daten abgemeldeter Konten. Die Wishlist des angemeldeten Kontos bleibt erhalten; du kannst sie selbst unter „Wishlist“ löschen.
- Durch das Deinstallieren der App werden alle Daten der App auf dem Gerät gelöscht.

### Auf dem Community-Server

- Du kannst deine Beiträge, Bewertungen, Kommentare und Mitspielersuchen direkt in der App selbst löschen und deine Stimmen zurücknehmen.
- Um alle mit deiner Riot ID verknüpften Community-Daten zu löschen, gehe zu Einstellungen > „Deine Community-Daten“ > „Meine Community-Daten löschen“. Der Server löscht dann dauerhaft deine Beiträge, Kommentare, Bewertungen, Likes, Stimmen, Mitspielersuchen, Bilder und dein Community-Konto. Dies kann nicht rückgängig gemacht werden. Du kannst auch eine E-Mail mit deiner Riot ID an ndh0408@gmail.com senden; wir können verlangen, dass du nachweist, Inhaber des Kontos zu sein, und bearbeiten die Anfrage innerhalb von 30 Tagen.
- Bilder: Bilddateien werden zusammen mit dem Beitrag oder Konto gelöscht. Bilder von Inhalten, die aufgrund von Meldungen ausgeblendet wurden, sind nicht mehr öffentlich abrufbar und werden nach 30 Tagen gelöscht; hochgeladene, aber nicht verwendete Bilder werden nach 24 Stunden gelöscht. Wenn du ein Bild hochlädst, entfernt der Server Standortinformationen und andere im Bild verborgene Daten (EXIF-Metadaten).
- Gelöschte Inhalte können noch bis zu 14 Tage in Sicherungskopien enthalten sein, bevor sie überschrieben werden.
- Hinweis: Wenn du dich von der App abmeldest, werden deine auf dem Community-Server veröffentlichten Inhalte nicht automatisch gelöscht.

## 12. Benachrichtigungen und Hintergrundaufgaben

ValHub verwendet ausschließlich lokale Benachrichtigungen, also Benachrichtigungen, die dein Gerät selbst erzeugt. Wir betreiben keinen Server für Push-Benachrichtigungen und erfassen keine Geräte-Tokens. Die App registriert beim Betriebssystem eine regelmäßige Hintergrundaufgabe, die direkt auf dem Gerät läuft, um deine Riot-Anmeldung gültig zu halten und, wenn du es aktivierst, den Shop direkt bei Riot abzurufen, um dich über Skins aus deiner Wishlist oder im Nachtmarkt zu benachrichtigen. Du kannst Benachrichtigungen in den Einstellungen der App oder des Betriebssystems deaktivieren.

## 13. Übersetzung von Inhalten auf dem Gerät

Wenn du dich entscheidest, Community-Inhalte zu übersetzen, verwendet ValHub das Übersetzungstool ML Kit von Google, das auf deinem Gerät läuft. Ist das benötigte Sprachpaket noch nicht vorhanden, fragt ValHub dich, bevor das Paket von Google heruntergeladen wird (etwa 30 MB pro Paket). Für den Download ist eine Netzwerkverbindung erforderlich, und Google kann technische Informationen über die Verbindung, etwa deine IP-Adresse, nach den Richtlinien von Google erhalten. Die Inhalte der Beiträge werden auf dem Gerät übersetzt und nicht zur Übersetzung an Google gesendet. Du musst diese Funktion nicht nutzen; ValHub verwendet keine Chatbots oder KI-Dienste zur Inhaltserstellung.

## 14. Analyse, Werbung und Tracking

ValHub bindet keine Analyse-Tools, keine Tools für automatische Absturzberichte, keine Werbung und keine Tracking-Tools von Drittanbietern ein. ValHub verwendet keine Werbe-IDs und verfolgt dich nicht über Apps oder Websites hinweg. Sollte sich dies künftig ändern, werden wir diese Datenschutzerklärung aktualisieren und, soweit gesetzlich erforderlich, deine Einwilligung einholen.

## 15. Datensicherheit

- Geheime Informationen (Riot-Anmeldedaten, gespeicherte Anmeldedaten, Community-Anmeldetoken) werden ausschließlich im sicheren Speicher des Betriebssystems (Keychain oder Keystore) gespeichert und bei einer Neuinstallation der App gelöscht.
- Alle Netzwerkverbindungen sind verschlüsselt (HTTPS/TLS).
- Fehlerberichte werden automatisch gefiltert, um Riot-Anmeldedaten, Passwörter und Konto-IDs zu entfernen.
- Der Community-Server speichert nur einen Einweg-Hash der PUUID; begrenzt die Anfragehäufigkeit (anhand eines gesalzenen Hashs der IP-Adresse); erlaubt dir nur, deine eigenen Inhalte zu löschen; und bewahrt geheime Schlüssel in der privaten Konfiguration des Servers auf, nicht im Quellcode.
- Wir erheben nur das für die jeweilige Funktion erforderliche Mindestmaß an Daten.

Keine Maßnahme ist absolut sicher. Kommt es zu einer Verletzung des Schutzes personenbezogener Daten, benachrichtigen wir die zuständigen Behörden und die betroffenen Nutzer gemäß den gesetzlichen Vorschriften.

## 16. Kinder

Die App richtet sich nicht an Kinder unter 13 Jahren. Wo das Gesetz ein höheres Mindestalter für die eigenständige Einwilligung in die Datenverarbeitung vorschreibt (z. B. 16 Jahre in einigen Ländern der Europäischen Union), darfst du die App, insbesondere die Community-Funktionen, nur nutzen, wenn du dieses Alter erreicht hast oder mit Einwilligung und unter Aufsicht eines Elternteils oder gesetzlichen Vormunds. Wenn du ein Elternteil bist und glaubst, dass dein Kind der Community ohne Einwilligung Daten bereitgestellt hat, kontaktiere uns bitte, damit wir diese Daten löschen.

## 17. Deine Rechte

Nach dem vietnamesischen Recht zum Schutz personenbezogener Daten (einschließlich Dekret Nr. 13/2023/NĐ-CP) hast du die folgenden Rechte:

- **Recht auf Information:** über die Verarbeitung deiner Daten informiert zu werden;
- **Recht auf Einwilligung:** in die Verarbeitung deiner Daten einzuwilligen oder nicht einzuwilligen;
- **Recht auf Zugang:** deine Daten einzusehen, zu berichtigen oder ihre Berichtigung zu verlangen;
- **Recht auf Widerruf der Einwilligung:** eine erteilte Einwilligung zu widerrufen;
- **Recht auf Löschung:** die Löschung deiner Daten zu verlangen;
- **Recht auf Einschränkung der Verarbeitung:** die Einschränkung der Verarbeitung deiner Daten zu verlangen;
- **Recht auf Bereitstellung der Daten:** die Bereitstellung deiner Daten zu verlangen;
- **Recht auf Widerspruch gegen die Verarbeitung:** der Verarbeitung deiner Daten für unerwünschte Zwecke zu widersprechen;
- **Recht auf Beschwerde und Schadensersatz:** nach Maßgabe der gesetzlichen Vorschriften Beschwerde und Anzeige zu erheben, Klage einzureichen und Schadensersatz zu verlangen;
- **Recht auf Selbstschutz:** deine personenbezogenen Daten selbst zu schützen.

Die meisten Daten befinden sich auf deinem Gerät, und du kannst sie direkt in der App selbst einsehen oder löschen. Für Daten auf dem Community-Server sende deine Anfrage an ndh0408@gmail.com. Wir bearbeiten Anfragen innerhalb von 30 Tagen und müssen gegebenenfalls zuvor deine Identität überprüfen. Du kannst außerdem selbst eine Kopie deiner Community-Daten (JSON-Datei) unter Einstellungen > „Deine Community-Daten“ > „Meine Daten herunterladen“ herunterladen und diese Daten dort auch selbst löschen.

## 18. Deine Rechte nach dem Recht deines Wohnorts

Je nach Wohnort kann dir das örtliche Recht zusätzliche Rechte gewähren. Wo auch immer du bist, kannst du die folgenden praktischen Rechte per E-Mail an ndh0408@gmail.com ausüben; wir bearbeiten Anfragen innerhalb von 30 Tagen und benachteiligen dich nicht, weil du deine Rechte ausübst.

- **Auskunft:** erfahren, welche Daten wir über dich gespeichert haben, und eine Kopie erhalten;
- **Löschung:** die Löschung der mit deiner Riot ID verknüpften Community-Daten verlangen (siehe Abschnitt „Löschen von Daten“);
- **Berichtigung:** unrichtige Daten berichtigen (dein Community-Profil wird bei jeder Verbindung aus deinem Riot-Konto aktualisiert);
- **Datenübertragbarkeit:** deine Daten in einem gängigen Format erhalten;
- **Widerspruch, Einschränkung und Widerruf der Einwilligung:** der Verarbeitung widersprechen oder ihre Einschränkung verlangen und deine Einwilligung jederzeit widerrufen;
- **Beschwerde:** Beschwerde bei der zuständigen Datenschutzbehörde an deinem Wohnort einlegen.

Einige Beispiele für Gesetze, die für dich gelten können:

- **DSGVO / UK GDPR:** Wenn du dich in der Europäischen Union, im Europäischen Wirtschaftsraum oder im Vereinigten Königreich befindest, hast du das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit, Widerspruch und Widerruf der Einwilligung sowie das Recht auf Beschwerde bei der Datenschutzaufsichtsbehörde des Landes, in dem du wohnst. Die Rechtsgrundlagen der Verarbeitung sind im Abschnitt „Rechtsgrundlagen“ aufgeführt.
- **CCPA / CPRA:** Wenn du in Kalifornien ansässig bist, hast du das Recht, Auskunft über deine Daten zu erhalten, sie löschen und berichtigen zu lassen und dem „Verkauf“ oder der „Weitergabe“ von Daten zu widersprechen. ValHub verkauft keine personenbezogenen Daten und gibt sie nicht für kontextübergreifende Werbung (cross-context behavioral advertising) weiter.
- **LGPD:** Wenn du dich in Brasilien befindest, hast du das Recht auf Auskunft, Berichtigung, Anonymisierung, Löschung, Datenübertragbarkeit und Information über die Weitergabe von Daten.
- **PIPL und ähnliche Gesetze:** Wenn du dich in Festlandchina oder an einem Ort mit ähnlichen Gesetzen befindest, hast du das Recht, informiert zu werden, zu entscheiden, die Verarbeitung einzuschränken oder abzulehnen, sowie das Recht auf Auskunft, Kopie, Berichtigung und Löschung von Daten und darauf, eine Erläuterung der Verarbeitung zu verlangen.
- **Dekret Nr. 13/2023/NĐ-CP:** Wenn du dich in Vietnam befindest, gelten die im Abschnitt „Deine Rechte“ oben genannten Rechte.

Wir erheben nicht mehr Daten als nötig und treffen keine automatisierten Entscheidungen, die dir gegenüber rechtliche Wirkung entfalten. Wenn du mit unserer Antwort nicht zufrieden bist, hast du das Recht, Beschwerde bei der zuständigen Behörde an deinem Wohnort einzulegen.

## 19. Änderungen dieser Datenschutzerklärung

Wir können diese Datenschutzerklärung aktualisieren, wenn sich die App oder die Rechtslage ändert. Version und Gültigkeitsdatum stehen immer am Anfang des Dokuments. Bei wesentlichen Änderungen der Datenverarbeitung informieren wir dich in der App und holen bei Bedarf erneut deine Einwilligung ein.

## 20. Kontakt

Bei Fragen oder Anliegen zu Datenschutz und personenbezogenen Daten wende dich bitte an:

- **Verantwortlicher:** Nguyễn Đức Huy
- **E-Mail:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Alle Rechte vorbehalten.
