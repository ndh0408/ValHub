<!-- Archivo generado automáticamente a partir de assets/legal/es/. No lo edites a mano: edita el contenido JSON y luego ejecuta `dart run tool/export_legal_docs.dart`. -->

# Política de privacidad

**ValHub** · Versión 1.2 · Vigente desde: 04/10/2026

Esta Política explica cómo ValHub recopila, usa, almacena y protege tus datos personales, así como los derechos que tienes sobre esos datos. Se ha elaborado conforme a la legislación vietnamita sobre protección de datos personales (Decreto n.º 13/2023/NĐ-CP, en vietnamita: Nghị định 13/2023/NĐ-CP) y tiene en cuenta además las normas que pueden ampararte en el lugar donde vives, como el RGPD (GDPR), el UK GDPR, la CCPA/CPRA o la LGPD (consulta la sección "Tus derechos según la ley del lugar donde vives"). ValHub está dirigida a jugadores de VALORANT de todos los países.

> Resumen: La mayoría de tus datos solo se guarda en tu dispositivo. Tus datos de inicio de sesión de Riot se almacenan en el almacenamiento seguro del sistema operativo y solo se usan en el servidor de ValHub después de que des tu consentimiento expreso: para verificar tu Riot ID cuando te conectas a la Comunidad y para comprobar la propiedad de skins cuando guardas una reseña. El token de acceso se destruye después de cada verificación. El servidor no almacena el PUUID (tu identificador de jugador). ValHub no tiene publicidad, no usa herramientas de análisis ni de seguimiento y no vende tus datos.

## 1. Responsable y encargado del tratamiento

Nguyễn Đức Huy ("nosotros") es quien decide los fines y los medios del tratamiento de datos personales en ValHub (responsable y encargado del tratamiento de datos personales). Los datos de contacto figuran en la última sección de esta Política.

## 2. Ámbito de aplicación

Esta Política se aplica a la aplicación ValHub para iOS y Android en todos los países, incluidas las funciones de la Comunidad. No se aplica a los servicios de Riot Games, valorant-api.com, Apple, Google ni de otros terceros. Cada uno de ellos trata los datos conforme a su propia política.

## 3. Datos tratados en tu dispositivo

Los datos que se indican a continuación se generan o se descargan cuando usas la aplicación y solo se guardan en tu dispositivo. Nosotros no recibimos estos datos.

- **Datos de inicio de sesión de Riot:** datos que Riot entrega a la aplicación después de que inicias sesión en la página oficial de Riot, entre ellos el token de acceso (access token), el token de derechos (entitlement token) y las cookies de inicio de sesión (archivos que ayudan a Riot a recordar que tienes la sesión iniciada). Se guardan en el llavero (Keychain) en iOS o en un almacenamiento cifrado protegido por Keystore en Android. ValHub nunca ve la contraseña que introduces en la página de Riot.
- **Datos de inicio de sesión guardados (opcional):** si decides guardar tu nombre de usuario y tu contraseña de Riot para volver a iniciar sesión más rápido, esta información solo permanece en el almacenamiento seguro del dispositivo. Nunca se escribe en los informes de errores ni se envía a ninguna parte, salvo para completar la página oficial de inicio de sesión de Riot cuando tú lo solicitas.
- **Lista de cuentas:** el Riot ID (nombre#tag), el identificador de jugador (PUUID), la región, la plataforma, la tarjeta de jugador, el nivel y el rango de las cuentas que añades. La aplicación los usa para mostrar la lista de cuentas y cambiar de una cuenta a otra.
- **Datos del juego:** tienda, monedero, colección, equipamiento, Battle Pass, contratos, historial de partidas, rango, partida actual, lista de amigos, estado en línea y mensajes de chat. La aplicación los lee directamente de los servidores de Riot con tu inicio de sesión de Riot y puede guardar una copia temporal para que puedas verlos sin conexión.
- **Lista de deseos y ajustes:** lista de deseos, preferencias de apariencia, ajustes de notificaciones y plataforma.
- **Datos temporales:** nombres e imágenes de objetos, agentes y mapas obtenidos de valorant-api.com, junto con las imágenes descargadas, que se guardan temporalmente para que la aplicación funcione más rápido.
- **Informes de errores:** un registro técnico, guardado en el dispositivo, de lo que ha hecho la aplicación (nombres de las solicitudes enviadas, resultados y tiempos), que se usa para encontrar errores. El registro se filtra para que no contenga contraseñas, datos de inicio de sesión de Riot ni ID de cuenta, y solo sale del dispositivo si tú eliges "Enviar informe de errores a ValHub" en Ajustes > Avanzado.

## 4. Datos tratados en el servidor de la Comunidad

El servidor de la Comunidad es un servidor que gestiona directamente el editor. Los datos se almacenan en la base de datos y en archivos del disco de ese servidor. Las conexiones de la Aplicación a este servidor pasan por la red de Cloudflare; Cloudflare solo retransmite las conexiones. Únicamente cuando usas las funciones de la Comunidad se envían a este servidor, y se almacenan en él, los datos siguientes:

- **Perfil de la Comunidad:** Riot ID (nombre y tag), región, tarjeta de jugador, rango e idioma de la aplicación, enviados por la Aplicación. Esta información es pública para los demás usuarios de la Comunidad.
- **País:** el país de tu Cuenta de Riot (lo proporciona Riot durante la verificación y no puedes modificarlo), que se usa para mostrar la Comunidad por país.
- **ID de usuario:** un hash unidireccional (a partir del cual no se puede obtener el PUUID) generado a partir de tu PUUID. El servidor no almacena ni devuelve tu PUUID.
- **Publicaciones y comentarios:** el contenido de tus publicaciones, las imágenes que subes, la información de la tienda o del Mercado nocturno que decides compartir, los comentarios, los "Me gusta" y el momento de publicación.
- **Reseñas de skins:** la puntuación en estrellas, el texto de la reseña y los votos de "Útil" que das a las reseñas de otras personas. Esta información se muestra públicamente junto con tu Riot ID. El servidor guarda el momento en que se comprobó la propiedad de la skin; las reseñas antiguas que no se han verificado se marcan claramente y no cuentan para la puntuación de la clasificación.
- **Anuncios de Buscar equipo:** código de grupo, modo de juego, región, límites de rango, roles buscados, si se requiere micrófono, idioma, tamaño del grupo, plazas libres, notas, estado (abierto, completo, jugando), número de toques en el grupo y la señal de "sigue activo" que la Aplicación envía periódicamente mientras el anuncio está abierto. El anuncio caduca automáticamente 30 minutos después de la última señal. Cada persona solo puede tener un anuncio activo.
- **Votos y "Me gusta":** las skins que votas, los "Me gusta" y el momento en que los das, que se usan para clasificar las skins favoritas.
- **Denuncias de infracciones:** el contenido denunciado, el motivo y quién lo denunció (en forma de ID de usuario), que se usan para la moderación.
- **Registros de acceso del servidor:** el servidor registra el tipo, la ruta, el resultado y el tiempo de procesamiento de cada solicitud para funcionar y encontrar errores. Las direcciones IP solo se usan en forma de hash con sal (un hash unidireccional al que se añade una cadena aleatoria) para limitar la frecuencia de las solicitudes, y no se registran en forma legible. Cloudflare puede tratar las direcciones IP al retransmitir las conexiones, conforme a su propia política.
- **Imágenes subidas:** las imágenes que publicas se guardan como archivos en el disco del servidor de la Comunidad y pueden abrirse mediante un enlace público. La forma de eliminarlas se explica en la sección "Eliminación de datos".
- **Copias de seguridad:** se hace una copia de seguridad del servidor a diario; las copias se conservan 14 días en el servidor del editor.

## 5. Token de acceso de Riot y verificación del Riot ID

Tus datos de inicio de sesión de Riot (token de acceso, token de derechos y cookies) solo se usan en el servidor de ValHub en los casos de verificación que se describen a continuación. Las cookies de inicio de sesión y las contraseñas no se envían al servidor de la Comunidad:

- Después de iniciar sesión en Riot, debes leer y elegir aceptar antes de seguir usando las funciones de la cuenta. La decisión se guarda por separado para cada cuenta y cada versión de la política. Si no aceptas, puedes cerrar la sesión de esa cuenta. Elegir aceptar no envía por sí solo ningún token de Riot; la aplicación solo envía el token de acceso por HTTPS cuando vuelve a conectarse a la Comunidad o cuando tú decides guardar una reseña de skin.
- El servidor consulta a Riot tu identidad (PUUID y Riot ID). Cuando guardas una reseña, el servidor también lee en Riot la propiedad de tus skins y comprueba que esa cuenta coincide con la persona que ha iniciado sesión en la Comunidad. El token de acceso y el token de derechos temporales no se almacenan ni se escriben en los registros; el servidor los destruye después de procesar la solicitud.
- El servidor emite para la Aplicación un token de inicio de sesión de la Comunidad independiente, válido durante 30 días. Este token se guarda en el almacenamiento seguro del dispositivo y se borra cuando cierras la sesión de la cuenta.
- El servidor de la Comunidad solo lee la información de identidad y la propiedad de skins para estas verificaciones; no compra objetos, no cambia tu equipamiento ni modifica tu Cuenta de Riot.

## 6. Finalidades del tratamiento

- Mostrar la información de la cuenta, la tienda, la colección, las partidas y las funciones que solicitas.
- Enviar notificaciones directamente en el dispositivo sobre la tienda, la lista de deseos y el Mercado nocturno, si las activas.
- Gestionar la Comunidad: verificar que quien publica es el titular del Riot ID y mostrar publicaciones, comentarios, anuncios de Buscar equipo y la clasificación de skins.
- Garantizar la seguridad: prevenir el spam, el abuso y el fraude; moderar el contenido denunciado; limitar el número de solicitudes que pueden enviarse en un periodo de tiempo.
- Encontrar y corregir errores cuando decides enviar un informe de errores a ValHub.
- Cumplir las obligaciones establecidas por la ley.

No usamos tus datos para publicidad, no elaboramos perfiles de comportamiento y no vendemos, alquilamos ni intercambiamos datos personales.

## 7. Base jurídica

- **Tu consentimiento:** eliges aceptar de forma expresa esta Política después de iniciar sesión, y das un consentimiento aparte al activar las notificaciones o al guardar los datos de inicio de sesión. Puedes retirar tu consentimiento en cualquier momento en Ajustes; en ese caso, debes volver a aceptar o cerrar sesión para seguir usando las funciones de la cuenta.
- **Ejecución de un acuerdo:** tratamiento necesario para ofrecerte las funciones que solicitas conforme a los Términos de uso.
- **Interés legítimo:** proteger la Comunidad frente al spam, el abuso y el fraude, moderar el contenido denunciado y mantener la seguridad del servidor, con los datos mínimos necesarios.
- **Obligación legal:** cuando la ley lo exige, por ejemplo, para responder a solicitudes lícitas de las autoridades públicas competentes.

## 8. Comunicación de datos a terceros

Solo compartimos datos en los casos siguientes:

- **Riot Games:** la Aplicación se conecta directamente a los servidores de Riot Games con tu inicio de sesión de Riot para leer los datos de la cuenta y realizar las acciones que solicitas.
- **valorant-api.com:** la Aplicación descarga datos públicos sobre objetos; no envía información de tu cuenta.
- **Archivos públicos:** la Aplicación puede descargar el estado público de los servidores de Riot y el archivo de configuración general de ValHub; estas solicitudes no incluyen datos personales.
- **Cloudflare, Inc.:** proporciona la red que retransmite las conexiones al servidor de la Comunidad. Cloudflare no almacena nuestros datos de la Comunidad, pero puede tratar datos técnicos, como las direcciones IP, conforme a su propia política.
- **Otros usuarios:** tu perfil de la Comunidad, tus publicaciones, imágenes, comentarios y anuncios de Buscar equipo son visibles para otros usuarios de ValHub. Las imágenes publicadas pueden abrirse mediante un enlace público.
- **Autoridades públicas competentes:** cuando exista una solicitud lícita conforme a la legislación aplicable al editor.

## 9. Transferencias internacionales de datos

El servidor de la Comunidad lo gestiona directamente el editor. Las conexiones a este servidor pasan por la red global de Cloudflare, Inc., por lo que los datos pueden transitar por varios países. Los datos de la Comunidad que publicas son visibles para usuarios de ValHub de todo el mundo. Cuando usas la Aplicación, tu dispositivo también se conecta directamente a los servidores de Riot Games. Aplicamos las garantías adecuadas y cumplimos las obligaciones relativas a la transferencia internacional de datos personales conforme a la legislación vietnamita y, si vives en un lugar con normas equivalentes, conforme a la ley del lugar donde vives.

## 10. Plazos de conservación

- **Datos en el dispositivo:** se conservan hasta que cierras la sesión de la cuenta correspondiente, borras los datos temporales o desinstalas la Aplicación. Las imágenes guardadas temporalmente se renuevan automáticamente al cabo de unos 30 días.
- **Anuncios de Buscar equipo:** caducan automáticamente y dejan de mostrarse 30 minutos después de la última señal de "sigue activo"; los datos caducados se eliminan periódicamente.
- **Publicaciones, reseñas, comentarios y votos:** se conservan hasta que los eliminas, hasta que los retiramos por una infracción o hasta que solicitas la eliminación de tus datos de la Comunidad.
- **Denuncias de infracciones:** se conservan como máximo 12 meses para gestionar infracciones y prevenir abusos, y después el servidor las elimina automáticamente. Las denuncias sobre contenido que ya se ha eliminado también se eliminan, y las denuncias que hayas enviado tú se anonimizan cuando eliminas tus datos de la Comunidad.
- **Registros de acceso del servidor:** solo se conserva el hash con sal (de la dirección IP) para limitar la frecuencia de las solicitudes; los registros técnicos solo se conservan durante el tiempo necesario para encontrar errores y por motivos de seguridad.
- **Copias de seguridad:** se conservan 14 días y después se sobrescriben; por eso, el contenido eliminado puede permanecer en las copias de seguridad hasta 14 días.
- **Token de inicio de sesión de la Comunidad:** caduca a los 30 días, se borra del dispositivo al cerrar sesión y se revoca en el servidor cuando hay conexión a internet.

## 11. Eliminación de datos

### En el dispositivo

- Cerrar la sesión de una cuenta en Ajustes borra del dispositivo los datos de inicio de sesión de Riot (token de acceso y cookies), los datos de inicio de sesión guardados, el token de inicio de sesión de la Comunidad, los datos temporales y las notificaciones programadas de esa cuenta. También se borran la lista de deseos, los conjuntos de equipamiento y el historial de RR, de partidas y de la tienda, salvo que en el cuadro de confirmación elijas conservar los datos locales para usarlos cuando vuelvas a iniciar sesión.
- "Borrar datos temporales", en Ajustes > Avanzado, borra las imágenes, los datos descargados para verlos sin conexión, los nombres de jugadores buscados y los informes de errores registrados en el dispositivo. Tu historial propio se conserva.
- "Borrar datos locales" borra el historial, los conjuntos de equipamiento y los datos conservados de las cuentas con la sesión cerrada. La lista de deseos de la cuenta con la sesión iniciada se mantiene; puedes borrarla tú desde Lista de deseos.
- Desinstalar la Aplicación borra todos los datos de la Aplicación en el dispositivo.

### En el servidor de la Comunidad

- Puedes eliminar tus propias publicaciones, reseñas, comentarios y anuncios de Buscar equipo, y retirar tus votos, directamente en la Aplicación.
- Para eliminar todos los datos de la Comunidad vinculados a tu Riot ID, ve a Ajustes > "Tus datos de la Comunidad" > "Eliminar mis datos de la Comunidad". El servidor eliminará de forma permanente tus publicaciones, comentarios, reseñas, "Me gusta", votos, anuncios de Buscar equipo, imágenes y tu cuenta de la Comunidad. Esta acción no se puede deshacer. También puedes enviar un correo electrónico a ndh0408@gmail.com indicando tu Riot ID; podemos pedirte que verifiques que eres el titular de la cuenta y tramitaremos la solicitud en un plazo de 30 días.
- Imágenes: los archivos de imagen se eliminan junto con la publicación o la cuenta. Las imágenes de contenido ocultado por haber sido denunciado dejan de ser accesibles públicamente y se eliminan a los 30 días; las imágenes subidas pero no utilizadas se eliminan a las 24 horas. Cuando subes una imagen, el servidor elimina la información de ubicación y otros datos ocultos de la imagen (metadatos EXIF).
- El contenido eliminado puede permanecer en las copias de seguridad hasta 14 días antes de sobrescribirse.
- Nota: cerrar sesión en la Aplicación no elimina automáticamente el contenido que hayas publicado en el servidor de la Comunidad.

## 12. Notificaciones y tareas en segundo plano

ValHub solo usa notificaciones locales, es decir, notificaciones que genera tu propio dispositivo. No gestionamos ningún servidor de notificaciones push ni recopilamos tokens de dispositivo. La Aplicación registra en el sistema operativo una tarea periódica en segundo plano, que se ejecuta en el propio dispositivo, para mantener válido tu inicio de sesión de Riot y, si lo activas, leer la tienda directamente de Riot para avisarte de skins de tu lista de deseos o del Mercado nocturno. Puedes desactivar las notificaciones en los ajustes de la Aplicación o del sistema operativo.

## 13. Traducción de contenido en el dispositivo

Cuando eliges traducir contenido de la Comunidad, ValHub usa la herramienta de traducción ML Kit de Google, que se ejecuta en el dispositivo. Si todavía no tienes el paquete de idioma necesario, ValHub te pregunta antes de descargarlo de Google (unos 30 MB por paquete). La descarga requiere conexión a internet y Google puede recibir información técnica de la conexión, como la dirección IP, conforme a la política de Google. El contenido de las publicaciones se traduce en el dispositivo y no se envía a Google para su traducción. Puedes no usar esta función; ValHub no usa chatbots ni servicios de generación de contenido con IA.

## 14. Análisis, publicidad y seguimiento

ValHub no integra herramientas de análisis, herramientas de informe automático de fallos, publicidad ni herramientas de seguimiento de terceros. ValHub no usa identificadores publicitarios y no te rastrea entre aplicaciones o sitios web. Si esto cambia en el futuro, actualizaremos esta Política y te pediremos tu consentimiento cuando la ley lo exija.

## 15. Seguridad de los datos

- La información secreta (datos de inicio de sesión de Riot, datos de inicio de sesión guardados, token de inicio de sesión de la Comunidad) solo se guarda en el almacenamiento seguro del sistema operativo (Keychain o Keystore) y se borra al reinstalar la Aplicación.
- Todas las conexiones de red están cifradas (HTTPS/TLS).
- Los informes de errores se filtran automáticamente para eliminar los datos de inicio de sesión de Riot, las contraseñas y los ID de cuenta.
- El servidor de la Comunidad solo almacena un hash unidireccional del PUUID; limita la frecuencia de las solicitudes (a partir de un hash con sal de la dirección IP); solo te permite eliminar tu propio contenido; y guarda las claves secretas en la configuración privada del servidor, no en el código fuente.
- Solo recopilamos los datos mínimos necesarios para cada función.

Ninguna medida es completamente segura. Si se produce una violación de la seguridad de los datos personales, lo notificaremos a las autoridades competentes y a los usuarios afectados conforme a la ley.

## 16. Menores

La Aplicación no está dirigida a menores de 13 años. Donde la ley establezca una edad mínima más alta para consentir por cuenta propia el tratamiento de datos (por ejemplo, 16 años en algunos países de la Unión Europea), solo puedes usar la Aplicación, en especial las funciones de la Comunidad, si ya tienes esa edad o con el consentimiento y la supervisión de tu padre, tu madre o tu tutor legal. Si eres padre o madre y crees que tu hijo o hija ha facilitado datos a la Comunidad sin el consentimiento necesario, ponte en contacto con nosotros para que eliminemos esos datos.

## 17. Tus derechos

Conforme a la legislación vietnamita sobre protección de datos personales (incluido el Decreto n.º 13/2023/NĐ-CP), tienes los siguientes derechos:

- **Derecho a ser informado:** a conocer las actividades de tratamiento de tus datos;
- **Derecho a dar el consentimiento:** a consentir o no el tratamiento de tus datos;
- **Derecho de acceso:** a consultar y corregir tus datos o solicitar que se corrijan;
- **Derecho a retirar el consentimiento:** a retirar el consentimiento que hayas dado;
- **Derecho de supresión:** a solicitar la eliminación de tus datos;
- **Derecho a la limitación del tratamiento:** a solicitar la limitación del tratamiento de tus datos;
- **Derecho a obtener tus datos:** a solicitar que se te faciliten tus datos;
- **Derecho de oposición al tratamiento:** a oponerte al tratamiento de tus datos con fines no deseados;
- **Derecho a reclamar y a ser indemnizado:** a presentar reclamaciones y denuncias, interponer demandas y solicitar una indemnización por daños y perjuicios conforme a la ley;
- **Derecho a la autoprotección:** a proteger por ti mismo tus datos personales.

La mayoría de los datos están en tu dispositivo, y puedes consultarlos o eliminarlos tú directamente en la Aplicación. Para los datos del servidor de la Comunidad, envía tu solicitud a ndh0408@gmail.com. Tramitamos las solicitudes en un plazo de 30 días y es posible que tengamos que verificar tu identidad antes de hacerlo. También puedes descargar tú una copia de tus datos de la Comunidad (archivo JSON) en Ajustes > "Tus datos de la Comunidad" > "Descargar mis datos", y eliminar esos datos desde ahí mismo.

## 18. Tus derechos según la ley del lugar donde vives

Según el lugar donde vivas, la legislación local puede concederte derechos adicionales. Estés donde estés, puedes ejercer los derechos prácticos que se indican a continuación enviando un correo electrónico a ndh0408@gmail.com; tramitamos las solicitudes en un plazo de 30 días y no te discriminaremos por ejercer tus derechos.

- **Acceso:** saber qué datos tenemos sobre ti y recibir una copia;
- **Supresión:** solicitar la eliminación de los datos de la Comunidad vinculados a tu Riot ID (consulta la sección "Eliminación de datos");
- **Rectificación:** corregir datos inexactos (el perfil de la Comunidad se actualiza a partir de tu cuenta de Riot cada vez que te conectas);
- **Portabilidad de los datos:** recibir tus datos en un formato de uso común;
- **Oposición, limitación y retirada del consentimiento:** oponerte al tratamiento o solicitar su limitación, y retirar el consentimiento en cualquier momento;
- **Reclamaciones:** presentar una reclamación ante la autoridad de protección de datos competente del lugar donde vives.

Algunos ejemplos de leyes que pueden aplicarse en tu caso:

- **RGPD (GDPR) / UK GDPR:** si estás en la Unión Europea, el Espacio Económico Europeo o el Reino Unido: tienes los derechos de acceso, rectificación, supresión, limitación, portabilidad de los datos, oposición y retirada del consentimiento, así como el derecho a presentar una reclamación ante la autoridad de control de protección de datos del país donde vives. Las bases del tratamiento se indican en la sección "Base jurídica".
- **CCPA / CPRA:** si resides en California: tienes derecho a saber, eliminar y corregir datos, y a oponerte a la "venta" o al "intercambio" ("sharing") de datos. ValHub no vende datos personales ni los comparte para publicidad conductual entre contextos.
- **LGPD:** si estás en Brasil: tienes los derechos de acceso, rectificación, anonimización, eliminación y portabilidad de los datos, y el derecho a recibir información sobre la comunicación de los datos a terceros.
- **PIPL y leyes similares:** si estás en China continental o en un lugar con leyes similares: tienes derecho a conocer, decidir, limitar, rechazar, acceder, copiar, corregir y eliminar datos, y a solicitar una explicación sobre el tratamiento.
- **Decreto n.º 13/2023/NĐ-CP:** si estás en Vietnam: los derechos indicados en la sección "Tus derechos" anterior.

No recopilamos más datos de los necesarios ni tomamos decisiones automatizadas que produzcan efectos jurídicos sobre ti. Si no estás conforme con nuestra respuesta, tienes derecho a presentar una reclamación ante la autoridad competente del lugar donde vives.

## 19. Cambios en esta Política

Podemos actualizar esta Política cuando cambien la Aplicación o la normativa. La versión y la fecha de entrada en vigor siempre figuran al principio del documento. Si hay cambios importantes en la forma de tratar los datos, te avisaremos en la Aplicación y, cuando sea necesario, volveremos a pedirte tu consentimiento.

## 20. Contacto

Si tienes cualquier pregunta o solicitud sobre privacidad y datos personales, ponte en contacto con:

- **Responsable del tratamiento:** Nguyễn Đức Huy
- **Correo electrónico:** ndh0408@gmail.com

---

© 2026 Nguyễn Đức Huy. Todos los derechos reservados.
