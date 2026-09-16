import SwiftUI

struct RouteHeaderView: View {
    let request: FlightSearchRequest
    let onEdit: () -> Void
    @ScaledMetric(relativeTo: .caption) private var controlWidth = 44.0

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: request.departureDate)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: "chevron.left")
                .font(.body)
                .frame(width: controlWidth, height: 44)
                .accessibilityHidden(true)

            VStack(spacing: 6) {
                Text("\(request.originCity) - \(request.destinationCity)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 5) {
                        Text(dateText)
                        Text("|").accessibilityHidden(true)
                        passengers
                        Text("|").accessibilityHidden(true)
                        Text("One Way")
                    }
                    .fixedSize()

                    VStack(spacing: 4) {
                        Text(dateText)
                        passengers
                        Text("One Way")
                    }
                }
                .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)

            Button(action: onEdit) {
                VStack(spacing: 2) {
                    Image(systemName: "pencil")
                        .font(.body)

                    Text("Edit")
                        .font(.caption.weight(.semibold))
                }
                .frame(minWidth: controlWidth, minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit search")
            .frame(width: controlWidth)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .foregroundStyle(.white)
        .background(Color(red: 0.035, green: 0.0, blue: 0.38))
    }

    private var passengers: some View {
        HStack(spacing: 3) {
            Image(systemName: "person")
            Text(String(format: "%02d", request.passengerCount))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(request.passengerCount) passengers")
    }
}

private extension RouteHeaderView {
    static func previewRequest(origin: String = "Dhaka", destination: String = "New York") -> FlightSearchRequest {
        FlightSearchRequest(
            originCode: "DAC", originCity: origin,
            destinationCode: "JFK", destinationCity: destination,
            departureDate: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2027, month: 2, day: 15))!,
            passengerCount: 2, currencyCode: "USD"
        )
    }
}

#Preview("Header · 375 points", traits: .sizeThatFitsLayout) {
    RouteHeaderView(request: RouteHeaderView.previewRequest(), onEdit: { print("Edit tapped") })
    .frame(width: 375)
}

#Preview("Header · long cities and large text", traits: .sizeThatFitsLayout) {
    RouteHeaderView(
        request: RouteHeaderView.previewRequest(origin: "San Francisco", destination: "Kuala Lumpur"),
        onEdit: { print("Edit tapped") }
    )
    .dynamicTypeSize(.accessibility3)
    .frame(width: 375)
}
