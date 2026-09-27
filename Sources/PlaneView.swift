import AppKit
import QuartzCore

/// Cambia aquí los colores, la fuente y la velocidad.
enum Style {
    static let bannerColor = NSColor(srgbRed: 0.667, green: 0.608, blue: 0.937, alpha: 0.96) // #aa9bef
    static let textColor   = NSColor.white
    static let planeColor  = NSColor(srgbRed: 0.827, green: 0.792, blue: 0.922, alpha: 1.0) // #d3caeb
    static let ropeColor   = NSColor(white: 0.35, alpha: 0.8)
    static let font        = NSFont.systemFont(ofSize: 22, weight: .semibold)
    static let speed: CGFloat = 250        // puntos por segundo
    static let heightRatio: CGFloat = 0.72 // altura del vuelo (0 = abajo, 1 = arriba)
}

final class PlaneView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) no se usa") }

    func fly(message: String, completion: @escaping () -> Void) {
        guard let root = layer else { completion(); return }
        let scale = window?.backingScaleFactor ?? 2

        let flight = makeFlight(message: message, scale: scale)
        let w = bounds.width
        let y = bounds.height * Style.heightRatio
        let half = flight.bounds.width / 2
        let start = CGPoint(x: -half - 40, y: y)
        let end = CGPoint(x: w + half + 40, y: y)

        // Posición final antes de entrar al árbol de capas, así no hay "salto".
        flight.position = end
        root.addSublayer(flight)

        // Trayectoria con una ondulación suave.
        let path = CGMutablePath()
        path.move(to: start)
        path.addCurve(to: end,
                      control1: CGPoint(x: w * 0.33, y: y + 60),
                      control2: CGPoint(x: w * 0.66, y: y - 60))

        let duration = min(max(Double((end.x - start.x) / Style.speed), 5), 12)

        let move = CAKeyframeAnimation(keyPath: "position")
        move.path = path
        move.duration = duration
        move.calculationMode = .paced
        flight.add(move, forKey: "fly")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            flight.removeFromSuperlayer()
            completion()
        }
    }

    // MARK: - Construcción del avión + cuerda + banner

    private func makeFlight(message: String, scale: CGFloat) -> CALayer {
        let attrs: [NSAttributedString.Key: Any] = [.font: Style.font, .foregroundColor: Style.textColor]
        let text = NSAttributedString(string: message, attributes: attrs)
        let textSize = text.size()
        let textH = ceil(textSize.height)

        let bannerW = ceil(textSize.width) + 44
        let bannerH = textH + 22
        let ropeW: CGFloat = 36
        let planeSize = CGSize(width: 72, height: 72)
        let totalW = bannerW + ropeW + planeSize.width
        let totalH = max(bannerH, planeSize.height)

        let flight = CALayer()
        flight.bounds = CGRect(x: 0, y: 0, width: totalW, height: totalH)

        // Cuerda (detrás de todo)
        let rope = CAShapeLayer()
        let ropePath = CGMutablePath()
        ropePath.move(to: CGPoint(x: bannerW - 4, y: totalH / 2))
        ropePath.addLine(to: CGPoint(x: bannerW + ropeW + 14, y: totalH / 2))
        rope.path = ropePath
        rope.strokeColor = Style.ropeColor.cgColor
        rope.lineWidth = 1.5
        rope.contentsScale = scale
        flight.addSublayer(rope)

        // Banner, anclado a su borde derecho para que "flamee" desde la cuerda
        let banner = CALayer()
        banner.bounds = CGRect(x: 0, y: 0, width: bannerW, height: bannerH)
        banner.anchorPoint = CGPoint(x: 1, y: 0.5)
        banner.position = CGPoint(x: bannerW, y: totalH / 2)
        banner.backgroundColor = Style.bannerColor.cgColor
        banner.cornerRadius = 8
        banner.shadowColor = NSColor.black.cgColor
        banner.shadowOpacity = 0.18
        banner.shadowRadius = 8
        banner.shadowOffset = CGSize(width: 0, height: -3)

        let label = CATextLayer()
        label.string = text
        label.alignmentMode = .center
        label.contentsScale = scale
        label.frame = CGRect(x: 0, y: (bannerH - textH) / 2, width: bannerW, height: textH)
        banner.addSublayer(label)
        flight.addSublayer(banner)

        // Avión
        let plane = CALayer()
        plane.frame = CGRect(x: bannerW + ropeW, y: (totalH - planeSize.height) / 2,
                             width: planeSize.width, height: planeSize.height)
        plane.contents = planeImage(size: planeSize)
        plane.contentsGravity = .resizeAspect
        plane.contentsScale = scale
        flight.addSublayer(plane)

        // Movimientos sutiles: el banner flamea y el avión sube y baja un poquito
        let wave = CABasicAnimation(keyPath: "transform.rotation.z")
        wave.fromValue = -0.035
        wave.toValue = 0.035
        wave.duration = 0.45
        wave.autoreverses = true
        wave.repeatCount = .infinity
        wave.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        banner.add(wave, forKey: "wave")

        let bob = CABasicAnimation(keyPath: "transform.translation.y")
        bob.fromValue = -3
        bob.toValue = 3
        bob.duration = 0.6
        bob.autoreverses = true
        bob.repeatCount = .infinity
        bob.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        plane.add(bob, forKey: "bob")

        return flight
    }

    /// Usa Resources/plane.png si existe (mirando hacia la derecha); si no, el símbolo "airplane" de Apple.
    private func planeImage(size: CGSize) -> NSImage? {
        if let custom = Bundle.main.image(forResource: "plane") { return custom }

        let config = NSImage.SymbolConfiguration(pointSize: size.height * 0.8, weight: .bold)
        guard let symbol = NSImage(systemSymbolName: "airplane", accessibilityDescription: nil)?
            .withSymbolConfiguration(config) else { return nil }

        return NSImage(size: symbol.size, flipped: false) { rect in
            symbol.draw(in: rect)
            Style.planeColor.set()
            rect.fill(using: .sourceAtop) // pinta el símbolo del color elegido
            return true
        }
    }
}
