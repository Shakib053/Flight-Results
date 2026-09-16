import SwiftUI

/// Display-only presentation of an already mapped and priced itinerary.
struct FlightCardView: View {
    let offer: FlightOffer
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .body) private var logoSize = 20.0
    @ScaledMetric(relativeTo: .caption) private var journeyWidth = 100.0

    private let ink = Color(red: 0.02, green: 0.18, blue: 0.23)
    private let muted = Color(red: 0.34, green: 0.40, blue: 0.50)
    private let navy = Color(red: 0.035, green: 0, blue: 0.38)
    private let blue = Color(red: 0.25, green: 0.47, blue: 0.80)

    var body: some View {
        VStack(spacing: 16) {
            header
            itinerary
            CardDivider()
                .stroke(Color(red: 0.84, green: 0.85, blue: 0.88), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                .frame(height: 1)
            footer
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var header: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 8))
        return layout {
            HStack(alignment: .top, spacing: 4) {
                AsyncImage(url: offer.airlineLogoURL) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        Image(systemName: "airplane")
                            .resizable().scaledToFit().padding(3)
                            .foregroundStyle(.white)
                            .background(navy, in: RoundedRectangle(cornerRadius: 4))
                    }
                }
                .frame(width: logoSize, height: logoSize)
                Text(offer.airlineName)
                    .font(.subheadline).foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 5) {
                ZStack {
                    Image("Get_Points")
                        .resizable()
                        .scaledToFit()
                    Image("icon")
                        .resizable()
                        .interpolation(.none)
                        .frame(width: 8, height: 7)
                }
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)
                Text("Get Points").font(.caption).foregroundStyle(muted)
            }
            .fixedSize()
        }
    }

    private var itinerary: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 8))
        return layout {
            airport(time: offer.departureTime, code: offer.departureAirportCode, arrival: false)
            journey
                .frame(maxWidth: typeSize.isAccessibilitySize ? .infinity : journeyWidth)
                .frame(maxWidth: .infinity)
            airport(time: offer.arrivalTime, code: offer.arrivalAirportCode, arrival: true)
        }
    }

    private func airport(time: String, code: String, arrival: Bool) -> some View {
        let alignment: HorizontalAlignment = arrival && !typeSize.isAccessibilitySize ? .trailing : .leading
        return VStack(alignment: alignment, spacing: 4) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text(time).font(.headline)
                    if arrival && offer.arrivalDayOffset > 0 { dayOffset }
                }.fixedSize()
                VStack(alignment: alignment, spacing: 2) {
                    Text(time).font(.headline)
                    if arrival && offer.arrivalDayOffset > 0 { dayOffset }
                }
            }
            Text(code).font(.caption).foregroundStyle(muted)
        }
        .foregroundStyle(ink)
        .layoutPriority(1)
    }

    private var dayOffset: some View {
        Text("+\(offer.arrivalDayOffset) Day")
            .font(.caption2)
            .foregroundStyle(Color(red: 1, green: 0.17, blue: 0.17))
            .fixedSize()
    }

    private var journey: some View {
        VStack(spacing: 7) {
            Text(durationText)
            ZStack {
                Rectangle().fill(blue).frame(height: 1)
                HStack(spacing: 0) {
                    endpoint
                    ForEach(0..<max(0, offer.stopCount), id: \.self) { _ in
                        Spacer(minLength: 2)
                        Circle().fill(blue).frame(width: 7, height: 7)
                    }
                    Spacer(minLength: 2)
                    endpoint
                }
            }.frame(height: 8)
            Text(offer.stopCount == 0 ? "Non-Stop" : "\(offer.stopCount) Stop")
        }
        .font(.caption).foregroundStyle(muted)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var endpoint: some View {
        Circle().fill(Color(red: 0.93, green: 0.96, blue: 1))
            .overlay { Circle().stroke(blue, lineWidth: 1) }
            .frame(width: 7, height: 7)
    }

    private var footer: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 8))
        return layout {
            Text("Flight Details").font(.caption.weight(.semibold))
                .underline().foregroundStyle(blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: typeSize.isAccessibilitySize ? .leading : .trailing, spacing: 6) {
                Text("Starting from").font(.caption).foregroundStyle(muted)
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        currency
                        price
                    }.fixedSize()
                    VStack(alignment: .leading, spacing: 4) {
                        currency
                        price
                    }
                }
            }.layoutPriority(1)
        }
    }

    private var currency: some View {
        Text(offer.currencyCode).font(.caption).foregroundStyle(muted)
    }

    private var price: some View {
        Text(priceText).font(.headline).foregroundStyle(navy)
    }

    private var durationText: String {
        "\(offer.totalDurationMinutes / 60)h \(offer.totalDurationMinutes % 60)m"
    }

    private var priceText: String {
        offer.price.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    private var accessibilitySummary: String {
        let arrivalDay = offer.arrivalDayOffset > 0
            ? ", \(offer.arrivalDayOffset) \(offer.arrivalDayOffset == 1 ? "day" : "days") later" : ""
        let stops = offer.stopCount == 0 ? "Non-stop" : "\(offer.stopCount) \(offer.stopCount == 1 ? "stop" : "stops")"
        return "\(offer.airlineName). Departs \(offer.departureAirportCode) at \(offer.departureTime). Arrives \(offer.arrivalAirportCode) at \(offer.arrivalTime)\(arrivalDay). Duration \(offer.totalDurationMinutes / 60) hours, \(offer.totalDurationMinutes % 60) minutes. \(stops). Starting from \(offer.currencyCode) \(priceText)."
    }
}

private struct CardDivider: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

private struct FlightCardPreview: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                card(stops: 0, days: 0, price: 37_400)
                card(stops: 1, days: 1, price: 78_880)
                card(stops: 2, days: 2, price: 1_237_400, airline: "Biman Bangladesh Airlines, Singapore Airlines & Qatar Airways")
            }.padding(16)
        }
        .background(Color(red: 0.035, green: 0, blue: 0.38))
    }

    private func card(stops: Int, days: Int, price: Int, airline: String = "Biman Bangladesh Airlines") -> some View {
        FlightCardView(offer: FlightOffer(
            id: "preview-\(stops)", airlineName: airline, airlineLogoURL: nil,
            departureAirportCode: "DAC", arrivalAirportCode: "BKK",
            departureTime: days == 0 ? "12:30" : "04:00",
            arrivalTime: days == 0 ? "16:50" : "08:20",
            arrivalDayOffset: days, totalDurationMinutes: days == 0 ? 280 : 1640,
            stopCount: stops, price: price, currencyCode: "BDT"
        ))
    }
}

#Preview("Cards · 320 points", traits: .fixedLayout(width: 320, height: 800)) {
    FlightCardPreview()
}
#Preview("Cards · 375 points", traits: .fixedLayout(width: 375, height: 850)) {
    FlightCardPreview()
}
#Preview("Cards · 430 points", traits: .fixedLayout(width: 430, height: 900)) {
    FlightCardPreview()
}
#Preview("Cards · accessibility", traits: .fixedLayout(width: 375, height: 900)) {
    FlightCardPreview().dynamicTypeSize(.accessibility3)
}
