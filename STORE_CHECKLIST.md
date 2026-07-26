# Google Play — checklist de publicación

App: **One more try.**  
Package: `com.studio.onemoretry.one_more_try`

## 1. Cuenta y costos

- [ ] Cuenta [Google Play Console](https://play.google.com/console) (pago único ~USD 25)
- [ ] Aceptar acuerdos de desarrollador

## 2. Firma de la app (obligatorio)

Generar keystore de upload (una sola vez, **guardalo seguro + backup**):

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

Build de producción:

```bash
flutter build appbundle --release
```

Salida: `build/app/outputs/bundle/release/app-release.aab`

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

## 7. Testing track

1. Subir `.aab` a **Prueba interna**
2. Probar en 1–2 dispositivos
3. Luego **producción** (revisión Google: horas–días)

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
