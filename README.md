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

Requires **Xcode 26+** and an **iOS 17+** simulator or device.

1. In `iOS-Flight-Results/iOS-Flight-Results/Configuration/`, copy `Secrets.example.xcconfig` to `Secrets.xcconfig`.
2. Replace the placeholder with your SerpApi key: `SERPAPI_API_KEY = "YOUR_ACTUAL_KEY"`. This secrets file is gitignored; `App.xcconfig` loads it automatically.
3. Open `iOS-Flight-Results/iOS-Flight-Results.xcodeproj`, select the `iOS-Flight-Results` scheme and an iPhone simulator, then press **⌘R**.

For a physical device, select your development team under Signing & Capabilities.

## Tests

Select the same scheme and an **iOS 26+ simulator**, then press **⌘U**. XCTest covers mapping/currency conversion, loading/success/empty/error states, retries, sorting, and coordinator composition/navigation. Tests use mocks and require no API key.

## Important decisions

- Searches request **USD**, converted locally to BDT before display and sorting at **1 USD = 123 BDT**. This fixed, non-live rate is injected by the coordinator; see [NOTES.md](NOTES.md) for the BDT API limitation found during development.
- The requested date's fare comes from returned offers; adjacent-date fares and promotions are sample data.
- Progress is simulated. Edit/Filter are decorative, date taps are display-only, and flight cards do not navigate.

## Demonstrate empty and error states

Open the existing `FlightResultsView` Xcode preview: it uses `MockFlightSearchService(result: .empty)`. For error, change the mock result to `.failure(URLError(.notConnectedToInternet))`.

To demonstrate either in the running app, temporarily replace `SerpApiFlightSearchService()` in `AppCoordinator` with the corresponding mock. Run with **⌘R**; retry repeats the mock outcome. Restore the live service afterward.
