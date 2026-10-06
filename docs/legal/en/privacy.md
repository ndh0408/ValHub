<!-- File generated automatically from assets/legal/en/. Do not edit by hand: edit the JSON content, then run `dart run tool/export_legal_docs.dart`. -->

# Privacy Policy

**ValHub** · Version 1.2 · Effective from: 04/10/2026

This Policy explains how ValHub collects, uses, stores and protects your personal data, and the rights you have over that data. It is based on Vietnamese law on personal data protection (Decree No. 13/2023/NĐ-CP (Nghị định 13/2023/NĐ-CP)), and also takes into account rules that may benefit you where you live, such as the GDPR, UK GDPR, CCPA/CPRA or LGPD (see the section "Your rights under the law where you live"). ValHub is for VALORANT players in every country.

> Summary: Most of your data stays only on your device. Your Riot sign-in data is stored in your operating system's secure storage and is used on the ValHub server only after your explicit consent: to verify your Riot ID when you connect to Community, and to check skin ownership when you save a review. The access token is discarded after each verification. The server does not store your PUUID (your player identifier). ValHub has no ads, uses no analytics or tracking tools, and does not sell your data.

## 1. Data controller and processor

Nguyễn Đức Huy ("we") decides the purposes and means of processing personal data in ValHub (the personal data controller and processor). Contact details are in the last section of this Policy.

## 2. Scope

This Policy applies to the ValHub app on iOS and Android in every country, including the Community features. It does not apply to the services of Riot Games, valorant-api.com, Apple, Google or other third parties. Each of them processes data under its own policy.

## 3. Data processed on your device

The data below is created or downloaded when you use the app, and is stored only on your device. We do not receive this data.

- **Riot sign-in data:** data that Riot issues to the app after you sign in on Riot's official page, including the access token, the entitlement token and sign-in cookies (files that help Riot remember that you are signed in). They are stored in the Keychain (iOS) or in encrypted storage protected by the Keystore (Android). ValHub never sees the password you enter on Riot's page.
- **Saved sign-in details (optional):** if you choose to save your Riot username and password to sign in again faster, this information stays only in secure storage on your device. It is never written into bug reports or sent anywhere, except to be filled into Riot's official sign-in page when you ask.
- **Account list:** the Riot ID (name#tag), player identifier (PUUID), region, platform, Player Card, level and rank of the accounts you add. The app uses them to show the account list and to switch between accounts.
- **Game data:** store, wallet, collection, loadout, Battle Pass, contracts, match history, rank, current match, friends list, online status and chat messages. The app reads these directly from Riot's servers using your Riot sign-in, and may keep a temporary copy so you can view them offline.
- **Wishlist and settings:** wishlist, appearance preferences, notification settings and platform.
- **Temporary data:** names and images of items, agents and maps from valorant-api.com, together with downloaded images, stored temporarily so the app runs faster.
- **Bug reports:** a technical log on your device of what the app has done (names of requests sent, results and timing), used to find bugs. The log is filtered so it does not contain passwords, Riot sign-in data or account IDs, and it only leaves your device when you choose "Send bug report to ValHub" in Settings > Advanced.

## 4. Data processed on the Community server

The Community server is a server operated by the publisher. Data is stored in the database and in files on that server's disk. Connections from the App to this server pass through Cloudflare's network; Cloudflare only relays the connections. Only when you use the Community features is the data below sent to and stored on this server:

- **Community profile:** Riot ID (name and tag), region, Player Card, rank and app language, sent by the App. This information is public to other users in Community.
- **Country:** the country of your Riot Account (provided by Riot during verification; you cannot edit it), used to show Community by country.
- **User ID:** a one-way hash (from which your PUUID cannot be derived) created from your PUUID. The server does not store or return your PUUID.
- **Posts and comments:** the content of your posts, images you upload, store or Night Market information you choose to share, comments, likes and posting times.
- **Skin reviews:** star ratings, review text and the "helpful" votes you give to other people's reviews. This information is shown publicly together with your Riot ID. The server stores when skin ownership was checked; older reviews that have not been verified are clearly marked and do not count toward the ranking score.
- **LFG posts:** party code, game mode, region, rank limits, roles wanted, whether a mic is required, language, party size, open slots, notes, status (open, full, in game), the number of taps on the party, and the "still active" signal that the App sends periodically while the post is open. A post expires automatically 30 minutes after the last signal. Each person can have only one active post.
- **Votes and likes:** the skins you vote for, your likes and when you made them, used to rank the most-loved skins.
- **Violation reports:** the reported content, the reason and the reporter (as a user ID), used for moderation.
- **Server access logs:** the server records the request type, path, result and processing time of each request in order to operate and find bugs. IP addresses are used only as a salted hash (a one-way hash with an added random string) to limit how often requests can be sent, and are not recorded in readable form. Cloudflare may process IP addresses when relaying connections, under its own policy.
- **Uploaded images:** images you post are stored as files on the Community server's disk and can be opened through a public link. How to delete images is described in the section "Deleting data".
- **Backups:** the server is backed up daily; backups are kept for 14 days on the publisher's server.

## 5. Riot access token and Riot ID verification

Your Riot sign-in data (access token, entitlement token and cookies) is used on the ValHub server only in the verification cases described below. Sign-in cookies and passwords are not sent to the Community server:

- After signing in to Riot, you must read and choose to agree before you continue using account features. Your decision is stored separately for each account and each policy version. If you do not agree, you can sign out of that account. Choosing to agree does not by itself send any Riot token; the app sends the access token over HTTPS only when reconnecting to Community or when you actively save a skin review.
- The server asks Riot for your identity (PUUID and Riot ID). When you save a review, the server also reads your skin ownership from Riot and checks that the account matches the person signed in to Community. The temporary access token and entitlement token are not stored or written to logs; the server discards them after processing the request.
- The server issues the App a separate Community sign-in token, valid for 30 days. This token is stored in secure storage on your device and is deleted when you sign out of the account.
- The Community server only reads identity information and skin ownership for these verifications; it does not buy items, change your loadout or make changes to your Riot Account.

## 6. Purposes of processing

- Showing account information, the store, your collection, matches and the features you request.
- Sending notifications directly on your device about the store, wishlist and Night Market, if you turn them on.
- Operating Community: verifying that the poster owns the Riot ID, and showing posts, comments, LFG posts and skin rankings.
- Ensuring safety: preventing spam, abuse and fraud; moderating reported content; limiting how many requests can be sent within a period of time.
- Finding and fixing bugs when you choose to send a bug report to ValHub.
- Complying with obligations required by law.

We do not use your data for advertising, do not build behavioral profiles, and do not sell, rent or trade personal data.

## 7. Legal basis

- **Your consent:** you choose to explicitly agree to this Policy after signing in, and give separate consent when turning on notifications or saving sign-in details. You can withdraw your consent at any time in Settings; you must then agree again or sign out to continue using account features.
- **Performance of an agreement:** processing necessary to provide the features you request under the Terms of Use.
- **Legitimate interests:** protecting Community from spam, abuse and fraud, moderating reported content and keeping the server secure, using the minimum data necessary.
- **Legal obligation:** when required by law, for example responding to lawful requests from competent public authorities.

## 8. Data sharing

We share data only in the following cases:

- **Riot Games:** the App connects directly to Riot Games' servers using your Riot sign-in to read account data and perform the actions you request.
- **valorant-api.com:** the App downloads public item data; it does not send your account information.
- **Public files:** the App may download Riot's public server status and ValHub's general configuration file; these requests do not include personal data.
- **Cloudflare, Inc.:** provides the network that relays connections to the Community server. Cloudflare does not store our Community data but may process technical data such as IP addresses under its own policy.
- **Other users:** your Community profile, posts, images, comments and LFG posts are visible to other ValHub users. Posted images can be opened through a public link.
- **Competent public authorities:** when there is a lawful request under the laws that apply to the publisher.

## 9. Cross-border data transfers

The Community server is operated by the publisher. Connections to this server pass through the global network of Cloudflare, Inc., so data may pass through several countries. Community data you post is visible to ValHub users everywhere. When you use the App, your device also connects directly to Riot Games' servers. We apply appropriate safeguards and fulfill the obligations relating to cross-border transfers of personal data under Vietnamese law and, where you live somewhere with corresponding rules, under the law where you live.

## 10. Retention periods

- **Data on your device:** kept until you sign out of the relevant account, clear temporary data or uninstall the App. Temporarily stored images refresh automatically after about 30 days.
- **LFG posts:** expire automatically and stop being shown 30 minutes after the last "still active" signal; expired data is deleted periodically.
- **Posts, reviews, comments, votes:** kept until you delete them, until we remove them for a violation, or until you request deletion of your Community data.
- **Violation reports:** kept for no more than 12 months to handle violations and prevent abuse, after which the server deletes them automatically. Reports about content that has been deleted are also deleted, and reports you sent yourself are anonymized when you delete your Community data.
- **Server access logs:** only the salted hash (of the IP address) is kept to limit how often requests can be sent; technical logs are kept only as long as necessary for finding bugs and for security.
- **Backups:** kept for 14 days and then overwritten; deleted content may therefore remain in backups for up to 14 days.
- **Community sign-in token:** expires after 30 days, is deleted from the device when you sign out, and is revoked on the server when a network connection is available.

## 11. Deleting data

### On your device

- Signing out of an account in Settings deletes from the device that account's Riot sign-in data (access token and cookies), saved sign-in details, Community sign-in token, temporary data and scheduled notifications. Wishlist, loadout presets and RR, match and store history are also deleted, unless you choose to keep local data in the confirmation dialog for use when you sign in again.
- "Clear temporary data" in Settings > Advanced deletes images, data downloaded for offline viewing, looked-up player names and bug reports recorded on the device. Your own history is kept.
- "Clear local data" deletes the history, loadout presets and retained data of signed-out accounts. The wishlist of the signed-in account remains; you can delete it yourself in Wishlist.
- Uninstalling the App deletes all of the App's data on the device.

### On the Community server

- You can delete your own posts, reviews, comments and LFG posts, and remove your votes, directly in the App.
- To delete all Community data linked to your Riot ID, go to Settings > "Your Community data" > "Delete my Community data". The server will permanently delete your posts, comments, reviews, likes, votes, LFG posts, images and Community account. This cannot be undone. You can also email ndh0408@gmail.com with your Riot ID; we may ask you to verify that you own the account and will handle the request within 30 days.
- Images: image files are deleted together with the post or account. Images belonging to content hidden because it was reported can no longer be accessed publicly and are deleted after 30 days; images uploaded but not used are deleted after 24 hours. When you upload an image, the server removes location information and other hidden data in the image (EXIF metadata).
- Deleted content may remain in backups for up to 14 days before being overwritten.
- Note: signing out of the App does not automatically delete content you have posted on the Community server.

## 12. Notifications and background tasks

ValHub uses only local notifications, meaning notifications created by your device itself. We do not operate a push notification server and do not collect device tokens. The App registers a periodic background task with the operating system, running directly on the device, to keep your Riot sign-in valid and, if you turn it on, to read the store directly from Riot to alert you about skins on your wishlist or in the Night Market. You can turn off notifications in the App's settings or in the operating system's settings.

## 13. On-device content translation

When you choose to translate Community content, ValHub uses Google's ML Kit translation tool running on your device. If the required language pack is not yet installed, ValHub asks you before downloading the pack from Google (about 30 MB per pack). The download requires a network connection, and Google may receive technical information about the connection, such as your IP address, under Google's policy. Post content is translated on the device and is not sent to Google for translation. You may choose not to use this feature; ValHub does not use chatbots or AI content-generation services.

## 14. Analytics, advertising and tracking

ValHub does not integrate third-party analytics tools, automatic crash reporting tools, advertising or tracking tools. ValHub does not use advertising identifiers and does not track you across apps or websites. If this changes in the future, we will update this Policy and ask for your consent where required by law.

## 15. Data security

- Secret information (Riot sign-in data, saved sign-in details, Community sign-in token) is stored only in the operating system's secure storage (Keychain or Keystore) and is deleted when the App is reinstalled.
- All network connections are encrypted (HTTPS/TLS).
- Bug reports are filtered automatically to remove Riot sign-in data, passwords and account IDs.
- The Community server stores only a one-way hash of the PUUID; limits how often requests can be sent (based on a salted hash of the IP address); only allows you to delete your own content; and keeps secret keys in the server's private configuration, not in the source code.
- We collect only the minimum data necessary for each feature.

No measure is perfectly secure. If a personal data breach occurs, we will notify the competent authorities and affected users as required by law.

## 16. Children

The App is not intended for children under 13. Where the law sets a higher minimum age for consenting to data processing on one's own (for example 16 in some European Union countries), you may use the App, especially the Community features, only once you have reached that age or with the consent and supervision of a parent or legal guardian. If you are a parent and believe your child has provided data to Community without consent, please contact us so we can delete that data.

## 17. Your rights

Under Vietnamese law on personal data protection (including Decree No. 13/2023/NĐ-CP), you have the following rights:

- **Right to be informed:** to be informed about the processing of your data;
- **Right to consent:** to consent or not consent to the processing of your data;
- **Right of access:** to view, correct or request correction of your data;
- **Right to withdraw consent:** to withdraw consent you have given;
- **Right to deletion:** to request deletion of your data;
- **Right to restrict processing:** to request restriction of the processing of your data;
- **Right to be provided with data:** to request that your data be provided to you;
- **Right to object to processing:** to object to the processing of your data for unwanted purposes;
- **Right to complain and claim compensation:** to file complaints and denunciations, bring lawsuits and claim compensation for damages as provided by law;
- **Right to self-protection:** to protect your own personal data.

Most data is on your device, and you can view or delete it yourself directly in the App. For data on the Community server, send your request to ndh0408@gmail.com. We handle requests within 30 days and may need to verify your identity before doing so. You can also download a copy of your Community data yourself (a JSON file) in Settings > "Your Community data" > "Download my data", and delete that data yourself in the same place.

## 18. Your rights under the law where you live

Depending on where you live, local law may give you additional rights. Wherever you are, you can exercise the practical rights below by emailing ndh0408@gmail.com; we handle requests within 30 days and will not discriminate against you for exercising your rights.

- **Access:** know what data we hold about you and receive a copy;
- **Deletion:** request deletion of the Community data linked to your Riot ID (see the section "Deleting data");
- **Correction:** correct inaccurate data (your Community profile is refreshed from your Riot account each time you connect);
- **Data portability:** receive your data in a commonly used format;
- **Objection, restriction and withdrawal of consent:** object to or request restriction of processing, and withdraw consent at any time;
- **Complaints:** lodge a complaint with the competent data protection authority where you live.

Some examples of laws that may apply to you:

- **GDPR / UK GDPR:** if you are in the European Union, the European Economic Area or the United Kingdom: you have the rights of access, rectification, erasure, restriction, data portability, objection and withdrawal of consent, as well as the right to lodge a complaint with the data supervisory authority in the country where you live. The legal bases for processing are set out in the section "Legal basis".
- **CCPA / CPRA:** if you are a California resident: you have the right to know, delete and correct data and to opt out of the "sale" or "sharing" of data. ValHub does not sell personal data and does not share it for cross-context behavioral advertising.
- **LGPD:** if you are in Brazil: you have the rights of access, correction, anonymization, deletion, data portability and information about data sharing.
- **PIPL and similar laws:** if you are in mainland China or somewhere with similar laws: you have the right to know, decide, restrict, refuse, access, copy, correct and delete data, and to request an explanation of the processing.
- **Decree No. 13/2023/NĐ-CP:** if you are in Vietnam: the rights set out in the section "Your rights" above.

We do not collect more data than necessary and do not make automated decisions that have legal effects on you. If you are not satisfied with our response, you have the right to lodge a complaint with the competent authority where you live.

## 19. Changes to this Policy

We may update this Policy when the App or the law changes. The version and effective date are always shown at the top of the document. For important changes to how data is processed, we will notify you in the App and ask for your consent again where needed.

## 20. Contact

For any questions or requests about privacy and personal data, please contact:

- **Data controller:** Nguyễn Đức Huy
- **Email:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. All rights reserved.
