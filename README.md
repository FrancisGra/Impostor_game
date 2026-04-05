# 🕵️ El Impostor — App Móvil Multiplataforma

[![CI/CD](https://github.com/FrancisGra/Impostor_game/actions/workflows/ci.yml/badge.svg)](https://github.com/FrancisGra/Impostor_game/actions/workflows/ci.yml)

> Asistente de partida para el juego social **El Impostor** — libre de anuncios, sin backend.  
> Construido con **Flutter** (Android + iOS desde un único codebase).

---

## 📱 Capturas de pantalla

| Inicio | Configuración | Revelar Rol | Ronda | Resultados |
|--------|---------------|-------------|-------|------------|
| Pantalla de bienvenida | Elegir jugadores, impostores y categoría | Flujo "pasa el teléfono" | Temporizador y controles | Revelar la palabra secreta |

---

## 🎮 Cómo se juega

1. **Crear partida**: elige cuántos jugadores (3–15), cuántos impostores y una categoría de palabras.
2. **Revelar roles** (flujo "pasa el teléfono"): cada jugador ve en privado si es Tripulante (y la palabra secreta) o Impostor.
3. **Ronda**: todos hablan sobre la palabra sin revelarla. El impostor intenta pasar desapercibido.
4. **Votar**: ¿quién es el impostor? Si lo descubren, ganan los tripulantes. Si no, gana el impostor.
5. **Fin de ronda**: se revelan los roles y la palabra. Puedes reiniciar con los mismos jugadores o empezar de nuevo.

---

## 🚀 Ejecución local

### Requisitos

| Herramienta | Versión mínima |
|-------------|---------------|
| Flutter SDK | 3.10.0 |
| Dart SDK | 3.0.0 |
| Android Studio / Xcode | Última estable |
| Java (para Android) | 17 |

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/FrancisGra/Impostor_game.git
cd Impostor_game

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo/emulador
flutter run

# 4. Ejecutar tests
flutter test

# 5. Análisis estático
flutter analyze
```

### Build local

```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (sin firma)
flutter build ios --release --no-codesign
```

---

## 🏗️ Arquitectura

```
lib/
├── main.dart              # Punto de entrada + AppNavigator
├── models/
│   ├── game_category.dart # Categoría con palabras
│   ├── game_config.dart   # Configuración de partida
│   ├── game_state.dart    # Estado de partida en curso
│   └── player.dart        # Jugador con rol asignado
├── providers/
│   └── game_provider.dart # Lógica + StateNotifier (Riverpod)
├── screens/
│   ├── home_screen.dart   # Pantalla principal
│   ├── setup_screen.dart  # Configuración de partida
│   ├── role_reveal_screen.dart  # Revelar roles
│   ├── round_screen.dart  # Ronda con temporizador
│   └── result_screen.dart # Resultados y reinicio
└── data/
    └── categories.dart    # Categorías y palabras predefinidas

test/
├── unit/
│   └── game_logic_test.dart   # Tests de asignación de roles
└── widget/
    └── screens_test.dart      # Tests de widgets de pantallas clave
```

**Stack tecnológico:**
- **UI**: Flutter + Material Design 3
- **Estado**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Persistencia**: [shared_preferences](https://pub.dev/packages/shared_preferences) (nombres de jugadores)
- **Tests**: `flutter_test` + `mockito`

---

## ⚙️ CI/CD — GitHub Actions

El workflow `.github/workflows/ci.yml` se ejecuta en cada push a `main` y en PRs:

| Job | Descripción |
|-----|-------------|
| **test** | `flutter analyze` + `flutter test --coverage` |
| **build-android** | Genera APK (arm64, armeabi, x86_64) y AAB |
| **build-ios** | Genera IPA firmado (o sin firma si no hay certificados) |
| **virustotal-scan** | Sube el APK a VirusTotal, adjunta el enlace al summary |
| **release** | Crea un GitHub Release con artefactos (sólo en tags `v*`) |

### Artefactos generados

- `android-apk`: APKs por arquitectura
- `android-aab`: App Bundle para Google Play
- `ios-ipa`: IPA para iOS
- `coverage-report`: reporte de cobertura de tests

---

## 🔐 Secretos requeridos

Configura los siguientes secretos en **Settings > Secrets and variables > Actions** de tu repositorio:

### Android (firma del APK)

| Secreto | Descripción |
|---------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Keystore codificado en Base64 (`base64 -w0 my-keystore.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | Contraseña del keystore |
| `ANDROID_KEY_ALIAS` | Alias de la clave dentro del keystore |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave |

**Generar un keystore de prueba:**
```bash
keytool -genkey -v \
  -keystore my-release-key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias impostor_key

# Codificar en Base64
base64 -w0 my-release-key.jks
```

> ⚠️ **Nunca commits el archivo `.jks` al repositorio.**

### iOS (firma del IPA)

| Secreto | Descripción |
|---------|-------------|
| `IOS_CERTIFICATE_BASE64` | Certificado `.p12` codificado en Base64 |
| `IOS_CERTIFICATE_PASSWORD` | Contraseña del certificado `.p12` |
| `IOS_PROVISION_PROFILE_BASE64` | Perfil de aprovisionamiento `.mobileprovision` en Base64 |
| `KEYCHAIN_PASSWORD` | Contraseña para el keychain temporal en CI |

> Si no se configuran los secretos de iOS, el CI genera un build sin firma (útil para pruebas).

### VirusTotal

| Secreto | Descripción |
|---------|-------------|
| `VT_API_KEY` | API Key de [VirusTotal](https://www.virustotal.com/gui/my-apikey) |

> Si `VT_API_KEY` no está configurado, el paso de VirusTotal se salta sin fallar el workflow.

---

## 🌍 Internacionalización (i18n)

La app está en **Español** por defecto. La estructura está preparada para añadir más idiomas:

1. Extraer cadenas a un archivo ARB (`lib/l10n/app_es.arb`).
2. Añadir nuevos archivos ARB (`app_en.arb`, `app_fr.arb`, etc.).
3. Configurar `flutter_localizations` y `intl`.

---

## 📋 Categorías de palabras

La app incluye 7 categorías predefinidas con 15 palabras cada una:

- 📍 **Lugares** (Aeropuerto, Playa, Hospital, …)
- 💼 **Profesiones** (Médico, Maestro, Policía, …)
- 🐾 **Animales** (León, Elefante, Pingüino, …)
- 🎬 **Películas** (El Rey León, Titanic, Matrix, …)
- 🍕 **Comidas** (Pizza, Sushi, Tacos, …)
- ⚽ **Deportes** (Fútbol, Baloncesto, Tenis, …)
- 🎒 **Objetos cotidianos** (Paraguas, Llave, Reloj, …)
- 🎲 **Aleatorio** (mezcla de todas las categorías)

---

## 🤝 Contribuir

1. Haz un fork del repositorio.
2. Crea una rama: `git checkout -b feature/mi-feature`.
3. Realiza tus cambios y asegúrate de que los tests pasen: `flutter test`.
4. Abre un Pull Request.

---

## 📄 Licencia

MIT © FrancisGra

