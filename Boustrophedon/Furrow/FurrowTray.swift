import SwiftUI

/// Role: Furrow. One custom hero surface. Ox-plough tray under the caption rail.
struct FurrowTray: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let dip = rect.height * 0.18
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + dip))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.width * 0.25, y: rect.minY + dip * 0.2)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + dip),
            control: CGPoint(x: rect.width * 0.75, y: rect.minY + dip * 0.2)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
