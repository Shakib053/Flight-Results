import Foundation

/// A static item in the horizontally scrolling date and fare strip.
struct DateFareOption: Identifiable, Equatable {
    let id: String
    let dayText: String
    let dateText: String
    let price: Int
    let currencyCode: String
    let isSelected: Bool
}
