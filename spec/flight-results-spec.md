# Flight Results - Technical Specification

**Project:** GoZayaan iOS Take-Home Task  
**Screen:** Flight Results  
**Architecture:** MVVM + Coordinator  

## Overview

Build a single Flight Results screen using SwiftUI. The app will launch directly into this screen with a predefined one-way search from Dhaka to New York for two passengers and a valid future date.

A separate search screen, edit flow, filtering flow, flight details and booking are outside the scope of this task.

## Screen content

The screen will follow the supplied Figma reference and include:

- Route header with origin, destination, date, passenger count, One Way and a decorative Edit action
- Horizontally scrollable date and price strip using hardcoded data; the selected date is highlighted and taps are ignored
- Cheapest/Fastest sorting control and a decorative Filter button
- Flight result cards showing airline, departure and arrival times, duration, stops, airport codes and starting price
- Horizontally scrollable discount cards placed between flight results
- Learn more action on each discount card

The loading and success states will follow the provided Figma frames. Empty and error states will use the same colors, typography and visual style.

## Screen states

### Loading

Shown while the flight request is in progress. It displays the route information, date strip, loading message, progress indicator and shimmering flight-card placeholders.

### Success

Shown when at least one valid flight offer is available. It displays the flight list, sorting control and discount carousel. The discount carousel is inserted after the second flight card when possible.

### Empty

Shown when the request and decoding succeed but no valid flight offers are produced. It uses a mobile adaptation of GoZayaan's No Flights Found design and includes a Try Again button that repeats the same search.

### Error

Shown when the request fails because of configuration, connectivity, server or decoding problems. It displays a user-friendly message and a Try Again button. Technical error details are not shown to the user.

## Data and mapping

Flight data will come from the SerpApi Google Flights Results API. The request will use a one-way trip, USD request currency and a valid future departure date. USD fares are converted locally to BDT using the fixed manual rate of 1 USD = 123 BDT before display and sorting. The API key will be provided through local configuration and excluded from source control.

The API response models will remain separate from the app's flattened FlightOffer model. Both best_flights and other_flights may be absent or empty and will be handled safely.

### Required models

The screen will use the following small, presentation-ready models. SerpApi's nested response will be decoded separately and mapped into these values before reaching the View.

```swift
struct FlightSearchRequest: Equatable {
    let originCode: String          // IATA code sent to the API, for example DAC
    let originCity: String          // City name shown in the route header
    let destinationCode: String     // IATA code sent to the API, for example JFK
    let destinationCity: String     // City name shown in the route header
    let departureDate: Date         // Date sent to the API and shown on screen
    let passengerCount: Int         // Displays 02 in the route header for this task
    let currencyCode: String        // Uses USD for the API request; mapped offers display BDT
}
```

The request is always one-way and uses English, so those values can remain fixed configuration for this assessment.

```swift
struct FlightOffer: Identifiable, Equatable {
    let id: String                       // Stable identity for rendering and updates
    let airlineName: String              // Airline or combined airline names on the card
    let airlineLogoURL: URL?             // Remote logo; nil uses a local placeholder
    let departureAirportCode: String     // Origin code shown below departure time
    let arrivalAirportCode: String       // Destination code shown below arrival time
    let departureTime: String            // Airport-local departure time shown on the card
    let arrivalTime: String              // Airport-local arrival time shown on the card
    let arrivalDayOffset: Int            // Shows +1 Day or +2 Day when the trip crosses dates
    let totalDurationMinutes: Int         // Used for the duration label and Fastest sorting
    let stopCount: Int                    // Used for Non-Stop, 1 Stop or 2 Stop
    let price: Int                        // Used for starting price and Cheapest sorting
    let currencyCode: String              // Displays BDT beside the price
}
```

```swift
struct DateFareOption: Identifiable, Equatable {
    let id: String              // Stable identity for the horizontal list
    let dayText: String         // Weekday shown in the date strip
    let dateText: String        // Day and month shown in the date strip
    let price: Int              // Hardcoded fare displayed below the date
    let currencyCode: String    // Displays BDT with the fare
    let isSelected: Bool        // Controls the highlighted date style
}
```

```swift
struct Promotion: Identifiable, Equatable {
    let id: String          // Stable identity for the carousel
    let imageName: String   // Local promotional image
    let title: String       // Promotion title shown on the card
    let url: URL            // Opened through the Coordinator from Learn more
}
```

The ViewModel state will represent loading, success with flight offers, empty and error. The sorting options are Cheapest and Fastest.

Mapping rules:

- Departure information comes from the first flight leg
- Arrival information comes from the last flight leg
- Total duration and price come from the itinerary group
- Stop count uses the number of layovers, falling back to the number of legs minus one when layovers are unavailable
- Empty flight groups are ignored safely
- Direct flights display Non-Stop; connecting flights display the appropriate stop count
- Multiple airline names are preserved for mixed-airline itineraries
- Missing airline logos use a local fallback
- Airport times are displayed as supplied without device-timezone conversion

best_flights and other_flights will be combined before sorting. The initial visible order is Cheapest, matching the Figma reference.

departure_token and booking_token are not used because their related flows are outside scope.

## Interactions

| Element | Behaviour |
|---|---|
| Edit | Decorative; no edit flow |
| Date and price strip | Scrollable; taps ignored |
| Cheapest/Fastest | Sorts the current results without another API request |
| Filter | Decorative; no filtering logic |
| Flight card | Display only; no details navigation |
| Learn more | Opens GoZayaan through the Coordinator |
| Try Again | Repeats the current flight request |

## Architecture

**Model and data layer**

- Defines the request, API response and FlightOffer models
- Performs networking and response decoding
- Maps nested flight data into FlightOffer values

**ViewModel**

- Owns the loading, success, empty and error state
- Starts and retries the flight request
- Applies Cheapest and Fastest sorting
- Reports the Learn more action through an abstract output
- Contains no navigation implementation and no reference to the concrete Coordinator

**View**

- Renders the current ViewModel state
- Displays the supplied data and forwards user interactions
- Contains no networking, mapping or sorting logic

**Coordinator**

- Creates the Flight Results feature and provides the predefined search request
- Handles the Learn more action and opens the external URL

## Test plan

Tests use a mocked flight service and saved SerpApi response fixtures. They must not call the live API or require SwiftUI or the concrete Coordinator.


### ViewModel tests

- Starting a request immediately exposes Loading.
- A successful response with one or more valid mapped offers exposes Success.
- A successful response that produces zero valid offers exposes Empty.
- Configuration, transport, server and decoding failures expose Error with user-safe copy.
- Selecting Cheapest sorts the existing offers by ascending price; selecting Fastest sorts them by ascending total duration. Neither selection issues another network request.


## Definition of done

- All four states are implemented
- Loading and success closely match the supplied Figma
- Empty and error follow the same visual language and provide Try Again
- Real SerpApi results load with a valid local API key
- Nested flight results are mapped safely into FlightOffer values
- Cheapest and Fastest sorting update the list without refetching
- The discount carousel scrolls horizontally between flight cards
- Learn more is handled through the Coordinator
- The ViewModel can be tested without SwiftUI or the Coordinator
- Unit tests pass and no API key is committed
- README and NOTES documentation are included
