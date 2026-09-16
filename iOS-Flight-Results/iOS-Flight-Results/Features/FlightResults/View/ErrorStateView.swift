import SwiftUI

/// Presentation-only failure state. The parent owns the retry action.
struct ErrorStateView: View {
    let onTryAgain: () -> Void

    private let background = Color(red: 0.93, green: 0.95, blue: 0.97)
    private let ink = Color(red: 0.02, green: 0.18, blue: 0.23)
    private let muted = Color(red: 0.34, green: 0.40, blue: 0.50)
    private let navy = Color(red: 0.035, green: 0, blue: 0.38)
    private let iconBackground = Color(red: 0.88, green: 0.95, blue: 1)
    private let accent = Color(red: 1, green: 0.80, blue: 0)

    var body: some View {
        GeometryReader { geometry in
            let outerPadding: CGFloat = geometry.size.width < 500 ? 16 : 32
            let cardPadding: CGFloat = geometry.size.width < 500 ? 24 : 48
            let iconSize = min(max(geometry.size.width * 0.24, 88), 120)

            ScrollView {
                VStack(spacing: 0) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: iconSize * 0.44, weight: .semibold))
                        .foregroundStyle(navy)
                        .frame(width: iconSize, height: iconSize)
                        .background(iconBackground, in: Circle())
                        .accessibilityHidden(true)

                    VStack(spacing: 18) {
                        Text("Something Went Wrong")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(ink)

                        Text("We couldn’t load flights. Please try again.")
                            .font(.body)
                            .foregroundStyle(muted)
                            .lineSpacing(4)
                    }
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    .padding(.top, 36)

                    Button(action: onTryAgain) {
                        Text("Try Again")
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

#Preview("Error · compact iPhone", traits: .fixedLayout(width: 320, height: 568)) {
    ErrorStateView(onTryAgain: {})
}

#Preview("Error · regular iPhone", traits: .fixedLayout(width: 393, height: 650)) {
    ErrorStateView(onTryAgain: {})
}

#Preview("Error · iPad", traits: .fixedLayout(width: 1024, height: 700)) {
    ErrorStateView(onTryAgain: {})
}

#Preview("Error · accessibility text", traits: .fixedLayout(width: 375, height: 667)) {
    ErrorStateView(onTryAgain: {})
        .dynamicTypeSize(.accessibility3)
}
