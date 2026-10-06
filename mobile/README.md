# Community Attendance - Flutter App

Aplicación Flutter de código abierto para registro de asistencia. Nombre, logos, colores y URL del backend se configuran sin tocar el código.

## Características
- Home público con **Escanear código** e **Iniciar sesión**.
- Escaneo QR sin login.
- Login para super administradores y coordinadores.
- Menú dinámico obtenido del backend según permisos del usuario.
- Asistencia manual autenticada.
- Gestión de jóvenes, tribus, proyectos, reportes y usuarios.
- QR individual del joven.
- Modo claro / oscuro desde el home público y desde el dashboard.
- Código fuente, nombres de clases y variables en inglés; textos visibles en español.
- Marca configurable: nombre, logos, colores y textos.

## Configuración de tu organización
1. Copia `config/app.example.json` a `config/app.json` (ignorado por git).
2. Ajusta los valores:

| Variable | Descripción |
|---|---|
| `APP_NAME` | Nombre visible de la app. |
| `APP_TAGLINE` | Texto bajo el logo en el inicio público (vacío = oculto). |
| `APP_SLOGAN` | Frase al pie del inicio público (vacío = oculta). |
| `APP_LOGO` | Logo para fondos claros: ruta de asset (`assets/branding/logo.png`) o URL `https://...`. |
| `APP_LOGO_ON_DARK` | Logo para fondos oscuros (opcional, usa `APP_LOGO` si está vacío). |
| `APP_PRIMARY_COLOR`, `APP_PRIMARY_SOFT_COLOR` | Color principal en ARGB hex, p. ej. `0xFF101B3D`. |
| `APP_ACCENT_COLOR`, `APP_ACCENT_DARK_COLOR` | Color de acento en ARGB hex. |
| `API_BASE_URL` | URL del backend. Por defecto `http://10.0.2.2:8000` (Android Emulator). |

3. Coloca tus logos en `assets/branding/` (ver `assets/branding/README.md`).
4. Ejecuta con `--dart-define-from-file=config/app.json`.

Sin configuración, la app funciona con un nombre genérico y un ícono en lugar de logo.

## Backend esperado
El frontend usa los endpoints del backend y adicionalmente espera:
- `GET /api/auth/menu`
- `GET /api/users/{id}/permissions`
- `PUT /api/users/{id}/permissions`

La versión actualizada del backend incluida junto con este frontend implementa esos endpoints.

## Ejecutar
Si ya tienes Flutter instalado:

```bash
flutter create . --platforms=android
flutter pub get
flutter run --dart-define-from-file=config/app.json
```

`flutter create .` solo genera los archivos nativos Android faltantes; no reemplaza `lib/`, `assets/` ni `pubspec.yaml`.

## Cámara Android
Después de `flutter create .`, verifica que `android/app/src/main/AndroidManifest.xml` incluya:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Producción
No uses una IP HTTP pública en producción. Configura HTTPS y define `API_BASE_URL` con el dominio del backend.
