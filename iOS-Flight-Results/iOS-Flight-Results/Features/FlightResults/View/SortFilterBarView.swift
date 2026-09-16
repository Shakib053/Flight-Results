import SwiftUI

/// Sort controls for the flight-result list; filtering is display-only for this assessment.
struct SortFilterBarView: View {
    let selectedSort: FlightResultsViewModel.SortOption
    let isSortEnabled: Bool
    let onSelectSort: (FlightResultsViewModel.SortOption) -> Void
    let onFilterTapped: () -> Void
    @State private var isSortMenuExpanded: Bool

    private let accent = Color(red: 1, green: 0.84, blue: 0)
    private let background = Color(red: 0.035, green: 0, blue: 0.38)
    private let sortBorder = Color(red: 188.0 / 255.0, green: 201.0 / 255.0, blue: 220.0 / 255.0)
    private let selectedSortBackground = Color(red: 0.91, green: 0.94, blue: 0.98)
    @ScaledMetric(relativeTo: .caption) private var controlWidth = 100.0
    @ScaledMetric(relativeTo: .caption) private var controlHeight = 32.0
    @ScaledMetric(relativeTo: .body) private var menuWidth = 240.0
    @ScaledMetric(relativeTo: .body) private var menuRowHeight = 54.0
    @ScaledMetric(relativeTo: .caption) private var labelSize = 12.0

    init(
        selectedSort: FlightResultsViewModel.SortOption,
        isSortEnabled: Bool,
        initiallyExpanded: Bool = false,
        onSelectSort: @escaping (FlightResultsViewModel.SortOption) -> Void,
        onFilterTapped: @escaping () -> Void
    ) {
        self.selectedSort = selectedSort
        self.isSortEnabled = isSortEnabled
        self.onSelectSort = onSelectSort
        self.onFilterTapped = onFilterTapped
        _isSortMenuExpanded = State(initialValue: initiallyExpanded && isSortEnabled)
    }

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
        .onChange(of: isSortEnabled) { isEnabled in
            if !isEnabled {
                isSortMenuExpanded = false
            }
        }
    }

    private var sortMenu: some View {
        Button {
            isSortMenuExpanded.toggle()
        } label: {
            HStack(spacing: 8) {
                Text(selectedSort.rawValue)
                Image(systemName: isSortMenuExpanded ? "chevron.up" : "chevron.down")
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
        .accessibilityHint(isSortEnabled
            ? (isSortMenuExpanded ? "Sort options expanded" : "Double tap to show sort options")
            : "Available after flights load")
        .accessibilityAddTraits(isSortMenuExpanded ? .isSelected : [])
        .overlay(alignment: .topLeading) {
            if isSortMenuExpanded {
                ZStack(alignment: .topLeading) {
                    Color.clear
                        .contentShape(Rectangle())
                        .frame(width: 1_000, height: 1_000, alignment: .topLeading)
                        .offset(x: -500, y: controlHeight + 8)
                        .onTapGesture {
                            isSortMenuExpanded = false
                        }

                    sortDropdown
                        .padding(.top, controlHeight + 8)
                }
            }
        }
        .zIndex(isSortMenuExpanded ? 1 : 0)
    }

    private var sortDropdown: some View {
        VStack(spacing: 0) {
            ForEach(FlightResultsViewModel.SortOption.allCases, id: \.self) { option in
                Button {
                    onSelectSort(option)
                    isSortMenuExpanded = false
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: labelSize, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: menuRowHeight, alignment: .leading)
                        .padding(.horizontal, 12)
                        .background {
                            if option == selectedSort {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(selectedSortBackground)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.rawValue)
                .accessibilityValue(option == selectedSort ? "Selected" : "Not selected")
                .accessibilityHint("Double tap to sort flights by \(option.rawValue.lowercased())")
                .accessibilityAddTraits(option == selectedSort ? .isSelected : [])
            }
        }
        .padding(8)
        .frame(width: menuWidth)
        .background(.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sort options")
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

#Preview("Sort filter · dropdown", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .cheapest,
        isSortEnabled: true,
        initiallyExpanded: true,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .frame(width: 375, height: 180, alignment: .top)
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

#Preview("Sort filter · fastest dropdown", traits: .sizeThatFitsLayout) {
    SortFilterBarView(
        selectedSort: .fastest,
        isSortEnabled: true,
        initiallyExpanded: true,
        onSelectSort: { _ in },
        onFilterTapped: {}
    )
    .frame(width: 375, height: 180, alignment: .top)
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
