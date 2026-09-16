import SwiftUI

/// Presentation-only progress: the request owns when this view is removed.
struct LoadingSkeletonView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    let isCompleting: Bool
    let promotions: [Promotion]
    let onLearnMore: (Promotion) -> Void
    @State private var startedAt = Date()
    @ScaledMetric(relativeTo: .headline) private var messageSize = 20.0

    private let background = Color(red: 0.035, green: 0, blue: 0.38)
    private let placeholder = Color(red: 65 / 255.0, green: 121 / 255.0, blue: 189 / 255.0)
    private let gradient = LinearGradient(
        colors: [Color(red: 1 / 255.0, green: 2 / 255.0, blue: 110 / 255.0),
                 Color(red: 29 / 255.0, green: 77 / 255.0, blue: 162 / 255.0)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        // A view-scoped timeline stops with the view; no timer or network delay survives it.
        TimelineView(.animation(minimumInterval: 1 / 30.0,
                                paused: reduceMotion || scenePhase != .active)) { context in
            let elapsed = max(0, context.date.timeIntervalSince(startedAt))
            let fraction = min(elapsed / 12, 1)
            let simulatedProgress = reduceMotion ? 0.41 : 0.9 * (1 - pow(1 - fraction, 3))
            let progress = isCompleting ? 1.0 : simulatedProgress

            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        Capsule().fill(.white)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(Color(red: 1, green: 111 / 255.0, blue: 0))
                                    .frame(width: geometry.size.width * progress)
                            }
                    }
                    .frame(height: 8)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: isCompleting)
                    .accessibilityHidden(true)

                    Text("Hang tight! We’re finding the best flight options for you.")
                        .font(.system(size: messageSize, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .padding(.top, 24)
                        .padding(.bottom, 28)

                    VStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            skeletonCard(elapsed: elapsed)
                                .accessibilityHidden(true)
                            if index == 1 {
                                DiscountCarouselView(promotions: promotions, onLearnMore: onLearnMore)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background.ignoresSafeArea(edges: .bottom))
        .onAppear { startedAt = Date() }
    }

    private func skeletonCard(elapsed: TimeInterval) -> some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 8) {
                    Circle().fill(placeholder).frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 6) {
                        Capsule().fill(placeholder)
                            .frame(width: max(0, geometry.size.width - 143), height: 8)
                        Capsule().fill(placeholder)
                            .frame(width: max(0, geometry.size.width - 143) / 2, height: 8)
                    }
                }
                RoundedRectangle(cornerRadius: 3)
                    .fill(placeholder).frame(width: 48, height: 16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(gradient)
            .overlay {
                if !reduceMotion {
                    let phase = elapsed.truncatingRemainder(dividingBy: 1.8) / 1.8
                    LinearGradient(colors: [.clear, .white.opacity(0.12), .clear],
                                   startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: geometry.size.width * (phase * 1.6 - 0.8))
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(height: 116)
    }
}

#Preview("Loading · 375 points") {
    LoadingSkeletonView(isCompleting: false, promotions: (1...7).map {
        Promotion(id: "preview-\($0)", imageName: "discount view",
                  title: "On International Flight\nBookings", url: URL(string: "https://gozayaan.com")!)
    }, onLearnMore: { _ in }).frame(width: 375)
}

#Preview("Loading · narrow, large text") {
    LoadingSkeletonView(isCompleting: false, promotions: (1...7).map {
        Promotion(id: "preview-\($0)", imageName: "discount view",
                  title: "On International Flight\nBookings", url: URL(string: "https://gozayaan.com")!)
    }, onLearnMore: { _ in }).frame(width: 320)
        .dynamicTypeSize(.accessibility3)
}
