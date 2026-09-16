import SwiftUI

/// Shared promotional content; navigation is forwarded to the feature output.
struct DiscountCarouselView: View {
    let promotions: [Promotion]
    let onLearnMore: (Promotion) -> Void

    @ScaledMetric(relativeTo: .caption) private var titleSize = 10.0
    @ScaledMetric(relativeTo: .caption2) private var linkSize = 8.0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var hasPositioned = false

    private let mint = Color(red: 229 / 255.0, green: 1, blue: 236 / 255.0)
    private let ink = Color(red: 0, green: 44 / 255.0, blue: 61 / 255.0)
    private let secondaryInk = Color(red: 85 / 255.0, green: 103 / 255.0, blue: 129 / 255.0)
    private let initialPosition = "promotion-initial-position"
    private var scale: Double { dynamicTypeSize.isAccessibilitySize ? titleSize / 10 : 1 }

    var body: some View {
        if !promotions.isEmpty {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(promotions) { promotion in
                            card(promotion)
                        }
                    }
                    .background(alignment: .leading) {
                        // A content-space anchor sets the reference's partial first card.
                        HStack(spacing: 0) {
                            Color.clear.frame(width: 120)
                            Color.clear.frame(width: 1).id(initialPosition)
                        }
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    }
                }
                .onAppear {
                    guard !hasPositioned else { return }
                    proxy.scrollTo(initialPosition, anchor: .leading)
                    hasPositioned = true
                }
            }
            .frame(height: 48 * scale)
        }
    }

    private func card(_ promotion: Promotion) -> some View {
        HStack(spacing: 8) {
            Image(promotion.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 64 * scale, height: 48 * scale)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(promotion.title)
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? titleSize : 10, weight: .semibold))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    onLearnMore(promotion)
                } label: {
                    HStack(spacing: 4) {
                        Text("Learn more").underline()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? linkSize : 8))
                    .foregroundStyle(secondaryInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Learn more about \(promotion.title)")
                .accessibilityHint("Opens GoZayaan")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 6)
        }
        .frame(width: 200 * scale, height: 48 * scale)
        .background(mint)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8).strokeBorder(mint, lineWidth: 1)
        }
    }
}
