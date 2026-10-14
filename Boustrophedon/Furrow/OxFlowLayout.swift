import SwiftUI

/// Role: Furrow. Wraps chips onto as many rows as the width allows.
struct OxFlowLayout: Layout {
    var spacing: CGFloat = OxSpace.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = finiteWidth(proposal.width)
        let rows = rows(for: subviews, maxWidth: width)
        let height = rows.reduce(CGFloat.zero) { $0 + $1.height } + spacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rows(for: subviews, maxWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: item.size.width, height: item.size.height)
                )
                x += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Item {
        var index: Int
        var size: CGSize
    }

    private struct Row {
        var items: [Item]
        var height: CGFloat
    }

    private func finiteWidth(_ proposed: CGFloat?) -> CGFloat {
        guard let proposed, proposed.isFinite, proposed > 0 else { return OxSpace.band }
        return proposed
    }

    private func rows(for subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current: [Item] = []
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        let limit = finiteWidth(maxWidth)
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = current.isEmpty ? size.width : rowWidth + spacing + size.width
            if current.isEmpty == false && needed > limit {
                rows.append(Row(items: current, height: rowHeight))
                current = [Item(index: index, size: size)]
                rowWidth = size.width
                rowHeight = size.height
            } else {
                current.append(Item(index: index, size: size))
                rowWidth = needed
                rowHeight = max(rowHeight, size.height)
            }
        }
        if current.isEmpty == false {
            rows.append(Row(items: current, height: rowHeight))
        }
        return rows
    }
}
