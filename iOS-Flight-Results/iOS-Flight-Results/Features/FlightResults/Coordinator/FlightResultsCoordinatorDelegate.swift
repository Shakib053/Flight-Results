import Foundation

/// Feature intent output; the ViewModel does not own navigation.
@MainActor
protocol FlightResultsCoordinatorDelegate: AnyObject {
    func didSelectPromotion(_ promotion: Promotion)
}
