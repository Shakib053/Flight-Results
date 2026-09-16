import SwiftUI

/// Sort controls for the flight-result list; filtering is display-only for this assessment.
struct SortFilterBarView: View {
    let selectedSort: FlightResultsViewModel.SortOption
    let isSortEnabled: Bool
    let onSelectSort: (FlightResultsViewModel.SortOption) -> Void
    let onFilterTapped: () -> Void

    private let accent = Color(red: 1, green: 0.84, blue: 0)
    private let background = Color(red: 0.035, green: 0, blue: 0.38)
    private let sortBorder = Color(red: 188.0 / 255.0, green: 201.0 / 255.0, blue: 220.0 / 255.0)
    @ScaledMetric(relativeTo: .caption) private var controlWidth = 100.0
    @ScaledMetric(relativeTo: .caption) private var controlHeight = 32.0
    @ScaledMetric(relativeTo: .caption) private var labelSize = 12.0

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                sortMenu
                Spacer(minLength: 0)
                filterButton
            }

            VStack(alignment: .leading, spacing: 16) {
                sortMenu
                filterButton
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(background)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(FlightResultsViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    onSelectSort(option)
                } label: {
                    if option == selectedSort {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selectedSort.rawValue)
                Image(systemName: "chevron.down")
            }
            .font(.system(size: labelSize, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(width: controlWidth, height: controlHeight)
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(sortBorder, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isSortEnabled)
        .accessibilityLabel("Sort flights")
        .accessibilityValue(selectedSort.rawValue)
        .accessibilityHint(isSortEnabled ? "Choose Cheapest or Fastest" : "Available after flights load")
    }

    private var filterButton: some View {
        Button(action: onFilterTapped) {
            Label("Filter", systemImage: "slider.horizontal.3")
                .font(.system(size: labelSize, weight: .bold))
                .labelStyle(.titleAndIcon)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .frame(width: controlWidth, height: controlHeight)
                .background(accent, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Filtering is not available")
    }
}

#Preview("Sort filter · loading", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .cheapest,
        isSortEnabled: false,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .frame(width: 375)
}

#Preview("Sort filter · cheapest", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .cheapest,
        isSortEnabled: true,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .frame(width: 375)
}

#Preview("Sort filter · fastest", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .fastest,
        isSortEnabled: true,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .frame(width: 375)
}

#Preview("Sort filter · large text", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .cheapest,
        isSortEnabled: true,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .dynamicTypeSize(.accessibility3)
    .frame(width: 375)
}
