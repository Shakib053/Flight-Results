import SwiftUI

/// Display-only dates and sample fares; scrolling never changes the search.
struct DateFareStripView: View {
    let options: [DateFareOption]
    let isLoading: Bool
    @ScaledMetric(relativeTo: .caption) private var chipWidth = 112.0
    @ScaledMetric(relativeTo: .body) private var iconSize = 40.0
    @ScaledMetric(relativeTo: .subheadline) private var skeletonWidth = 96.0
    @ScaledMetric(relativeTo: .subheadline) private var skeletonHeight = 20.0

    private let accent = Color(red: 1, green: 0.84, blue: 0)

    var body: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(options) { option in
                        chip(option)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "chart.xyaxis.line")
                .font(.title3)
                .foregroundStyle(accent)
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(accent, lineWidth: 1)
                }
                .padding(.trailing, 16)
                .accessibilityHidden(true)
        }
        .background(Color(red: 0.035, green: 0, blue: 0.38))
    }

    private func chip(_ option: DateFareOption) -> some View {
        let fare = "\(option.currencyCode) \(option.price.formatted(.number.locale(Locale(identifier: "en_US"))))"
        return VStack(spacing: 8) {
            Text("\(option.dayText) \(option.dateText)")
                .font(.caption)
            if isLoading {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color(red: 0.08, green: 0.27, blue: 0.65))
                    .frame(width: skeletonWidth, height: skeletonHeight)
                    .accessibilityHidden(true)
            } else {
                Text(fare)
                    .font(.subheadline.weight(option.isSelected ? .semibold : .regular))
            }
        }
        .fixedSize(horizontal: true, vertical: true)
        .frame(minWidth: chipWidth)
        .padding(.horizontal, 4)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .foregroundStyle(option.isSelected ? accent : .white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(option.isSelected ? accent : .clear)
                .frame(height: 3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLoading
            ? "\(option.dayText) \(option.dateText), fare loading"
            : "\(option.dayText) \(option.dateText), \(fare)")
        .accessibilityAddTraits(option.isSelected ? .isSelected : [])
    }
}

private extension DateFareStripView {
    static let previewOptions: [DateFareOption] = [
        .init(id: "2026-02-08", dayText: "Sun", dateText: "08 Feb", price: 70_129, currencyCode: "BDT", isSelected: true),
        .init(id: "2026-02-09", dayText: "Mon", dateText: "09 Feb", price: 74_240, currencyCode: "BDT", isSelected: false),
        .init(id: "2026-02-10", dayText: "Tue", dateText: "10 Feb", price: 120_400, currencyCode: "BDT", isSelected: false),
        .init(id: "2026-02-11", dayText: "Wed", dateText: "11 Feb", price: 82_650, currencyCode: "BDT", isSelected: false)
    ]
}

#Preview("Date fares · 375 points", traits: .sizeThatFitsLayout) {
    DateFareStripView(options: DateFareStripView.previewOptions, isLoading: false)
        .frame(width: 375)
}

#Preview("Date fares · loading", traits: .sizeThatFitsLayout) {
    DateFareStripView(options: DateFareStripView.previewOptions, isLoading: true)
        .frame(width: 375)
}

#Preview("Date fares · large text", traits: .sizeThatFitsLayout) {
    DateFareStripView(options: DateFareStripView.previewOptions, isLoading: false)
        .dynamicTypeSize(.accessibility3)
        .frame(width: 375)
}
