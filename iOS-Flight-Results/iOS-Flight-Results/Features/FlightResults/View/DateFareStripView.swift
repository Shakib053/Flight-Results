import SwiftUI

/// Display-only dates and sample fares; scrolling never changes the search.
struct DateFareStripView: View {
    let options: [DateFareOption]
    let isLoading: Bool
    @ScaledMetric(relativeTo: .caption) private var chipWidth = 112.0
    @ScaledMetric(relativeTo: .body) private var iconSize = 40.0
    @ScaledMetric(relativeTo: .subheadline) private var skeletonWidth = 72.0
    @ScaledMetric(relativeTo: .subheadline) private var skeletonHeight = 12.0

    private let accent = Color(red: 1, green: 0.84, blue: 0)
    private var chartColor: Color { isLoading ? Color(red: 188 / 255.0, green: 201 / 255.0, blue: 220 / 255.0) : accent }

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
                .foregroundStyle(chartColor)
                .frame(width: iconSize, height: iconSize)
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(chartColor, lineWidth: 1)
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
                    .fill(LinearGradient(
                        colors: [Color(red: 1 / 255.0, green: 2 / 255.0, blue: 110 / 255.0),
                                 Color(red: 29 / 255.0, green: 77 / 255.0, blue: 162 / 255.0)],
                        startPoint: .leading, endPoint: .trailing))
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
        .foregroundStyle(option.isSelected && !isLoading ? accent : .white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(option.isSelected && !isLoading ? accent : .clear)
                .frame(height: 3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLoading
            ? "\(option.dayText) \(option.dateText), fare loading"
            : "\(option.dayText) \(option.dateText), \(fare)")
        .accessibilityAddTraits(option.isSelected && !isLoading ? .isSelected : [])
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
