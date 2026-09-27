import AppKit
import EventKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    /// Cuántos minutos antes de la reunión aparece el avioncito.
    private let minutesBefore: Double = 5

    private var statusItem: NSStatusItem!
    private let nextMeetingItem = NSMenuItem(title: "Próxima reunión: —", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Abrir al iniciar sesión", action: #selector(toggleLogin(_:)), keyEquivalent: "")

    private let calendar = CalendarWatcher()
    private var timer: Timer?
    private var announced: [String: Date] = [:]   // reuniones ya anunciadas
    private var queue: [String] = []               // mensajes pendientes si hay varias a la vez
    private var isFlying = false
    private var overlay: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()

        calendar.requestAccess { [weak self] granted in
            guard let self else { return }
            if !granted { self.showAccessAlert() }
            self.check()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.check()
        }
    }

    // MARK: - Revisar el calendario

    private func check() {
        let now = Date()
        announced = announced.filter { $0.value > now.addingTimeInterval(-3600) }

        for event in calendar.upcomingEvents(within: minutesBefore * 60 + 60) {
            let secondsLeft = event.startDate.timeIntervalSince(now)
            guard secondsLeft > 0, secondsLeft <= minutesBefore * 60 else { continue }

            let key = "\(event.eventIdentifier ?? event.title ?? "")-\(event.startDate.timeIntervalSince1970)"
            guard announced[key] == nil else { continue }
            announced[key] = event.startDate

            let minutes = max(1, Int((secondsLeft / 60).rounded()))
            let title = (event.title?.isEmpty == false) ? event.title! : "Reunión"
            fly("\(title) en \(minutes) min")
        }
    }

    // MARK: - Vuelo

    private func fly(_ message: String) {
        queue.append(message)
        if !isFlying { flyNext() }
    }

    private func flyNext() {
        guard !queue.isEmpty else { isFlying = false; return }
        isFlying = true
        let message = queue.removeFirst()

        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) })
            ?? NSScreen.main ?? NSScreen.screens[0]

        let window = OverlayWindow(screen: screen)
        overlay = window
        window.orderFrontRegardless()
        window.planeView.fly(message: message) { [weak self] in
            window.orderOut(nil)
            self?.overlay = nil
            self?.flyNext()
        }
    }

    // MARK: - Menú en la barra superior

    private func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "airplane", accessibilityDescription: "Avioncito")
        }

        let menu = NSMenu()
        menu.delegate = self
        nextMeetingItem.isEnabled = false
        menu.addItem(nextMeetingItem)
        menu.addItem(.separator())

        let test = NSMenuItem(title: "Probar avioncito", action: #selector(testFlight), keyEquivalent: "t")
        test.target = self
        menu.addItem(test)

        loginItem.target = self
        menu.addItem(loginItem)
        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)

        statusItem.menu = menu
    }

    func menuWillOpen(_ menu: NSMenu) {
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off

        if let next = calendar.upcomingEvents(within: 24 * 3600).first(where: { $0.startDate > Date() }) {
            let f = DateFormatter()
            f.dateStyle = .none
            f.timeStyle = .short
            nextMeetingItem.title = "Próxima: \(next.title ?? "Reunión") · \(f.string(from: next.startDate))"
        } else {
            nextMeetingItem.title = "Sin reuniones en las próximas 24 h"
        }
    }

    @objc private func testFlight() {
        fly("Reunión de prueba en 5 min")
    }

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSSound.beep()
            NSLog("Avioncito: no se pudo cambiar el inicio automático: \(error)")
        }
        sender.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    private func showAccessAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Avioncito necesita acceso a tu calendario"
        alert.informativeText = "Actívalo en Configuración del Sistema → Privacidad y seguridad → Calendarios."
        alert.addButton(withTitle: "Abrir Configuración")
        alert.addButton(withTitle: "Ahora no")
        if alert.runModal() == .alertFirstButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
            NSWorkspace.shared.open(url)
        }
    }
}
