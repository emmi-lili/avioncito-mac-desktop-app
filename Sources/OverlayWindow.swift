import AppKit

/// Ventana transparente del tamaño de la pantalla, siempre encima de todo
/// y que deja pasar los clics. Aquí vuela el avioncito.
final class OverlayWindow: NSWindow {
    let planeView: PlaneView

    init(screen: NSScreen) {
        planeView = PlaneView(frame: NSRect(origin: .zero, size: screen.frame.size))
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true          // los clics pasan a lo que está debajo
        level = .screenSaver               // encima de casi todo
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false

        contentView = planeView
        setFrame(screen.frame, display: true)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
