# Avioncito ✈️

[English](#english) · [Español](#español)

---

## English

A macOS menu bar app: 5 minutes before every meeting, a little airplane flies across your screen towing a banner that says "Meeting X in 5 min".

### Before you start

1. **Xcode Command Line Tools.** If you've never installed them, run `xcode-select --install` in Terminal.
2. **Your Google Calendar in the macOS Calendar app.** Open Calendar → Settings → Accounts → "+" → Google and sign in. On that same screen, set "Refresh Calendars" to **Push** or **Every 5 minutes** so new meetings sync quickly.

### Install

Unzip the folder, open Terminal inside it and run:

```bash
chmod +x build.sh
./build.sh install
```

The first time, macOS will ask for permission to read your calendar. Allow it. An airplane icon appears in the menu bar (top right). From there you can pick "Probar avioncito" (test flight) to watch it fly, and "Abrir al iniciar sesión" (open at login) so it starts automatically when you turn on your Mac.

### Customize

Colors, font, speed and flight height live at the top of `Sources/PlaneView.swift`, inside `Style`. The number of minutes before the meeting is set in `Sources/AppDelegate.swift` (`minutesBefore`). To use your own airplane, save a transparent PNG facing right as `Resources/plane.png`. After any change, run `./build.sh install` again.

### Troubleshooting

If it never asked for permission, or you denied it, go to System Settings → Privacy & Security → Calendars and turn on Avioncito. macOS may ask for permission again after you rebuild. That's normal for locally signed apps.

### Privacy

Avioncito never connects to the internet. It reads your calendar locally, only to know when your next meeting starts, and it doesn't store or send your data anywhere.

### Official repository

The only official source is [github.com/emmi-lili/avioncito-mac-desktop-app](https://github.com/emmi-lili/avioncito-mac-desktop-app). Copies downloaded from anywhere else may have been modified.

### License

MIT. See [LICENSE](LICENSE).

---

## Español

App de barra de menú para macOS: 5 minutos antes de cada reunión, un avioncito cruza tu pantalla con un banner que dice "Reunión X en 5 min".

### Antes de empezar

1. **Xcode Command Line Tools.** Si nunca las instalaste, corre `xcode-select --install` en la Terminal.
2. **Tu Google Calendar en la app Calendario de macOS.** Abre Calendario → Configuración → Cuentas → "+" → Google e inicia sesión. En esa misma pantalla, pon "Actualizar calendarios" en **Push** o **Cada 5 minutos** para que las reuniones nuevas lleguen rápido.

### Instalar

Descomprime la carpeta, abre la Terminal dentro de ella y corre:

```bash
chmod +x build.sh
./build.sh install
```

La primera vez, macOS te pedirá permiso para leer tu calendario. Acepta. Aparece un avión en la barra de menú (arriba a la derecha). Ahí tienes "Probar avioncito" para verlo volar y "Abrir al iniciar sesión" para que arranque solo al prender tu Mac.

### Personalizar

Los colores, la fuente, la velocidad y la altura del vuelo están al inicio de `Sources/PlaneView.swift`, en `Style`. Los minutos de aviso están en `Sources/AppDelegate.swift` (`minutesBefore`). Si quieres tu propio avión, guarda un PNG transparente mirando hacia la derecha en `Resources/plane.png`. Después de cualquier cambio, vuelve a correr `./build.sh install`.

### Si algo no funciona

Si no te pidió permiso o lo negaste, ve a Configuración del Sistema → Privacidad y seguridad → Calendarios y activa Avioncito. Al recompilar, macOS puede volver a pedirte el permiso. Eso es normal en apps firmadas localmente.

### Privacidad

Avioncito nunca se conecta a internet. Lee tu calendario de forma local, solo para saber cuándo empieza tu próxima reunión, y no guarda ni envía tus datos a ningún lado.

### Repositorio oficial

La única fuente oficial es [github.com/emmi-lili/avioncito-mac-desktop-app](https://github.com/emmi-lili/avioncito-mac-desktop-app). Las copias descargadas desde otro lugar podrían estar modificadas.

### Licencia

MIT. Ver [LICENSE](LICENSE).