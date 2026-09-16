import SwiftUI

/// Presentation-only empty result state. The parent owns the search action.
struct EmptyStateView: View {
    let onSearchAgain: () -> Void

    private let background = Color(red: 0.93, green: 0.95, blue: 0.97)
    private let ink = Color(red: 0.02, green: 0.18, blue: 0.23)
    private let muted = Color(red: 0.34, green: 0.40, blue: 0.50)
    private let navy = Color(red: 0.035, green: 0, blue: 0.38)
    private let accent = Color(red: 1, green: 0.80, blue: 0)

    var body: some View {
        GeometryReader { geometry in
            let outerPadding: CGFloat = geometry.size.width < 500 ? 16 : 32
            let cardPadding: CGFloat = geometry.size.width < 500 ? 24 : 48
            let imageWidth = min(max(geometry.size.width * 0.42, 140), 220)

            ScrollView {
                VStack(spacing: 0) {
                    Image("not found")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth)
                        .accessibilityHidden(true)

                    VStack(spacing: 18) {
                        Text("No Flights Found")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(ink)

                        Text("It looks like there are no flights matching your search criteria. Try adjusting your dates, destinations, or travel class to find available flights.")
                            .font(.body)
                            .foregroundStyle(muted)
                            .lineSpacing(4)
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    .padding(.top, 36)

                    Button(action: onSearchAgain) {
                        Text("Search Again")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(navy)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 15)
                            .frame(minWidth: 190, minHeight: 44)
                            .background(accent, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Repeats the current flight search")
                    .padding(.top, 24)
                }
                .frame(maxWidth: 720)
                .padding(.horizontal, cardPadding)
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity)
                .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, outerPadding)
                .padding(.vertical, 24)
                .frame(minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea(edges: .bottom))
    }
}

#Preview("Empty · compact iPhone", traits: .fixedLayout(width: 320, height: 568)) {
    EmptyStateView(onSearchAgain: {})
}

#Preview("Empty · regular iPhone", traits: .fixedLayout(width: 393, height: 650)) {
    EmptyStateView(onSearchAgain: {})
}

#Preview("Empty · iPad", traits: .fixedLayout(width: 1024, height: 700)) {
    EmptyStateView(onSearchAgain: {})
}

#Preview("Empty · accessibility text", traits: .fixedLayout(width: 375, height: 667)) {
    EmptyStateView(onSearchAgain: {})
        .dynamicTypeSize(.accessibility3)
}
