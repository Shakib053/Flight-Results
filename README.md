# GoZayaan Flight Results

A SwiftUI flight-results app powered by SerpApi's Google Flights API. It searches one-way flights from **Dhaka (DAC) to New York (JFK)** for two adults, departing 30 days ahead. Results include flight cards, cheapest/fastest sorting, a date-fare strip, and a promotion carousel with working links.

**Tech stack:** SwiftUI, Combine, XCTest, SerpApi

## Architecture

**MVVM + Coordinators:** SwiftUI views render `FlightResultsViewModel` state; coordinators compose dependencies and handle promotion navigation. The injected `FlightSearchServicing` protocol supports live and mock services. API DTOs are converted into display models by `FlightOfferMapper`.

## Screen states

- **Loading:** Animated skeleton with simulated progress.
- **Success:** Flight results with cheapest/fastest sorting.
- **Empty:** No matching results, with retry.
- **Error:** Failure message, with retry.

## Setup and run

The app targets **iOS 17+**. The project was created with Xcode 26.0.1; Xcode 26.0.1 or later is recommended.

1. In `iOS-Flight-Results/iOS-Flight-Results/Configuration/`, copy `Secrets.example.xcconfig` to `Secrets.xcconfig`.
2. Replace the placeholder with your SerpApi key: `SERPAPI_API_KEY = "YOUR_ACTUAL_KEY"`. This secrets file is gitignored; `App.xcconfig` loads it automatically.
3. Open `iOS-Flight-Results/iOS-Flight-Results.xcodeproj`, select the `iOS-Flight-Results` scheme and an iPhone simulator, then press **⌘R**.

For a physical device, select your development team under Signing & Capabilities.

## Tests

Select the same scheme and an **iOS 17+ simulator**, then press **⌘U**. XCTest covers SerpApi's nested flights and layovers mapping (including a multi-leg, two-stop result), currency conversion, loading/success/empty/error states, retries, sorting, and coordinator composition/navigation. Tests use mocks and require no API key.

## Important decisions

- Searches request **USD**, converted locally to BDT before display and sorting at **1 USD = 123 BDT**. This fixed, non-live rate is injected by the coordinator; see [NOTES.md](NOTES.md) for the BDT API limitation found during development.
- The requested date's fare comes from returned offers; adjacent-date fares and promotions are sample data.
- Progress is simulated. Edit/Filter are decorative, date taps are display-only, and flight cards do not navigate.

## Demonstrate all four states

- **Loading:** Launch the app normally; the loading skeleton appears while the search runs.
- **Success:** Launch with a valid SerpApi key.
- **Error:** Launch with a missing or invalid key, or while offline.
- **Empty:** Open the `FlightResultsView` preview, which uses a private service that returns no flights. To run the full app in this state, temporarily inject an empty `FlightSearchServicing` stub in `AppCoordinator`, then restore `SerpApiFlightSearchService()` afterward.
