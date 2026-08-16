# Google Play — checklist de publicación

App: **One more try.**  
Package: `one.more.try`

## 1. Cuenta y costos

- [ ] Cuenta [Google Play Console](https://play.google.com/console) (pago único ~USD 25)
- [ ] Aceptar acuerdos de desarrollador

## 2. Firma de la app (obligatorio) — ✅ hecho

Keystore ya generada (`android/keystore/upload-keystore.jks`) y `android/key.properties` configurado.
`.aab` de release ya compilado y firmado con esa key: `build/app/outputs/bundle/release/app-release.aab` (v1.0.1, versionCode 10).

**Importante:** Play Console rechaza un `.aab` si su versionCode ya fue subido antes (aunque sea a un track de prueba). Antes de cada subida, subí el número después del `+` en `version:` de `pubspec.yaml` (ej. `1.0.1+10` → `1.0.1+11`) y volvé a compilar.

Para regenerar tras el próximo cambio de versión (subí `version:` en `pubspec.yaml`, formato `X.Y.Z+N`, `N` siempre mayor al anterior):

```powershell
$env:PATH = "$env:LOCALAPPDATA\flutter\bin;$env:PATH"
flutter build appbundle --release
```

Salida: `build/app/outputs/bundle/release/app-release.aab` — **este es el archivo que se sube a Play Console** (no el `.apk`).

Pasos históricos para generar la keystore (ya no hace falta repetir, dejado como referencia):

```powershell
cd d:\Juegos\One\one_more_try\android\keystore
& "C:\Program Files\Microsoft\jdk-17.0.19.10-hotspot\bin\keytool.exe" `
  -genkey -v `
  -keystore upload-keystore.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload `
  -dname "CN=Facundo Sebastian Planella, OU=Planella, O=Planella, L=Buenos Aires, ST=Buenos Aires, C=AR"
```

Crear `android/key.properties` desde `android/key.properties.example` (no se sube al repo):

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

`android/app/build.gradle.kts` ya usa esa firma automáticamente si existe `key.properties`.

## 3. AdMob (producción)

- [ ] Crear app + unidad **Banner** en AdMob
- [ ] Reemplazar IDs de **test** en:
  - `lib/core/constants/game_constants.dart`
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`
- [ ] Configurar mensaje de consentimiento UMP (EEA/UK)

## 4. Assets de tienda

| Asset | Tamaño | Estado |
|-------|--------|--------|
| Ícono de alta res | 512×512 PNG | `assets/branding/app_icon.png` (adaptar a 512) |
| Feature graphic | 1024×500 | Pendiente |
| Screenshots teléfono | mín. 2 (ideal 4–8) | Pendiente — capturar del juego |
| (Opcional) video | YouTube 15–30 s | Pendiente |

## 5. Ficha de la tienda

- [ ] Título: `One more try.`
- [ ] Descripción corta (80 chars)
- [ ] Descripción completa
- [ ] Categoría: Arcade / Casual
- [ ] Contacto de email
- [x] **URL de política de privacidad** (obligatoria con ads)

### Política de privacidad

Publicada en: https://sites.google.com/view/onemoretry-privacy

Texto fuente: `PRIVACY_POLICY.md`. También enlazada dentro del juego en Settings → Privacy policy.

## 6. Formularios Play Console

- [ ] Clasificación de contenido (Everyone / PEGI 3)
- [ ] Público objetivo
- [ ] **Data safety**: declarar publicidad (AdMob)
- [ ] Declarar que hay ads
- [ ] Países de distribución

## 7. Fase de prueba (testing track)

Google exige pasar por testing antes de producción si la cuenta de desarrollador es nueva (creada desde nov. 2023): **mínimo 12 testers activos durante 14 días seguidos** en un track de **Prueba cerrada** antes de poder publicar en producción. Prueba interna no cuenta para ese requisito, pero es más rápida para probar el build vos mismo.

### 7.1 Prueba interna (primero — feedback inmediato, sin espera de revisión)

1. Play Console → tu app → **Testing → Internal testing** → **Create new release**
2. Subí `build/app/outputs/bundle/release/app-release.aab`
3. Completá "Release notes" (ej: "Primera build de prueba")
4. **Testers** → pestaña → creá una lista de emails (los tuyos + gente de confianza) o generá el link de opt-in y compartilo
5. Los testers necesitan aceptar la invitación (el link de opt-in) antes de poder instalar desde Play Store con esa cuenta
6. No hay revisión de Google — disponible en minutos

### 7.2 Prueba cerrada (obligatoria antes de producción, cuenta nueva)

1. **Testing → Closed testing** → crear track (ej. "Prueba cerrada")
2. Subí el mismo `.aab` (o promocioná el release desde Internal testing)
3. Cargá **al menos 12 testers** que acepten el opt-in y abran la app
4. Dejalo activo **14 días corridos** con esos testers interactuando (no basta con instalarla una vez y listo — Google mide uso real)
5. Play Console va a mostrar el progreso de este requisito en la sección de producción una vez que esté disponible

### 7.3 Anuncios durante testing

Los IDs de AdMob en el código **son los de test oficiales de Google** (`ca-app-pub-3940256099942544/...`) — correcto para esta fase, no los cambies todavía. Recién reemplazalos por los reales (paso 3 de este documento) cuando vayas a subir el release de **producción**, nunca antes: mostrar ads reales en testing viola la política de tráfico inválido de AdMob.

### 7.4 Formularios previos al primer release (se piden antes de poder subir cualquier track)

Play Console te va a pedir completar esto para habilitar publicar en cualquier track:

- **Content rating**: cuestionario → sin violencia, sin contenido para adultos, sin compras, sin chat/usuarios generando contenido → da PEGI 3 / Everyone
- **Data safety**: basado en `PRIVACY_POLICY.md` y en que la app usa `google_mobile_ads` + `shared_preferences` local:
  - No se recopilan datos personales del usuario (sin login, sin nombre/email/teléfono)
  - **Sí** se comparte con terceros: identificadores de publicidad (Advertising ID) vía Google AdMob, para mostrar anuncios y prevenir fraude
  - No hay datos financieros, ubicación precisa, ni contactos
  - Datos de juego (puntaje, progreso) se guardan solo localmente en el dispositivo, no se transmiten
  - Marcar "Datos cifrados en tránsito": sí (lo maneja el SDK de Google Ads)
  - Marcar que el usuario puede pedir borrado de datos: no aplica (no hay cuenta ni servidor propio)
- **Ads declaration**: marcar que la app **sí** muestra anuncios
- **Target audience / público objetivo**: elegí el rango de edad real esperado (probablemente 13+ o "todas las edades" según cómo definas el público — si marcás que apunta también a niños, AdMob tiene restricciones extra, mejor marcar audiencia general sin apuntar a niños si el juego no está diseñado específicamente para eso)
- **App access**: "Todas las funciones están disponibles sin restricciones" (no hay login)

### 7.5 Producción

Una vez cumplido el requisito de prueba cerrada (12 testers × 14 días) y completados los formularios: **Production → Create new release**, subir `.aab` con IDs reales de AdMob, revisión de Google (horas a días).

## 8. Post-lanzamiento

- Monitorear crashes en Play Console
- No hace falta servidor: mantenimiento bajo
- Updates: skins / misiones / modos nuevos

## Comandos útiles

```bash
# APK local (testing)
flutter build apk --release

# Bundle Play Store
flutter build appbundle --release
```
