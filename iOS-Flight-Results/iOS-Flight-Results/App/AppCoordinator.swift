import Combine
import SwiftUI
import UIKit

@MainActor
final class AppCoordinator: ObservableObject {
    let flightResultsCoordinator: FlightResultsCoordinator

    init() {
        flightResultsCoordinator = FlightResultsCoordinator(service: SerpApiFlightSearchService()) { url in
            UIApplication.shared.open(url)
        }
    }

    func makeRootView() -> FlightResultsView {
        flightResultsCoordinator.makeView()
    }
}
