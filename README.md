# FM Horizonte 94.3/101.9 - App Android

App Flutter que reproduce el stream en vivo de FM Horizonte (HLS).

## Requisitos

- Flutter SDK instalado (https://docs.flutter.dev/get-started/install)
- Android SDK / Android Studio

## Correr en modo desarrollo

```
flutter pub get
flutter run
```

## Generar APK / AAB para Play Store

1. Crear un keystore para firmar la app:

```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Crear `android/key.properties` con:

```
storePassword=<tu_password>
keyPassword=<tu_password>
keyAlias=upload
storeFile=/ruta/absoluta/upload-keystore.jks
```

3. Generar el bundle (.aab) para subir a Play Console:

```
flutter build appbundle --release \
  -PstoreFile=/ruta/absoluta/upload-keystore.jks \
  -PstorePassword=<tu_password> \
  -PkeyAlias=upload \
  -PkeyPassword=<tu_password>
```

El archivo queda en `build/app/outputs/bundle/release/app-release.aab`.

## Notas

- El logo se encuentra en `assets/logo.png` (reemplazar por el logo real de la radio).
- El ícono de la app está en `android/app/src/main/res/mipmap-*/ic_launcher.png` (reemplazar por el logo real, recomendado generar con https://icon.kitchen).
- La URL del stream está definida en `lib/main.dart` (constante `streamUrl`).
