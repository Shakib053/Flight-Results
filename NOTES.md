# AI-Assisted Development Process & Decisions

Spec was written first, in `/spec`, before any prompting.

## AI Tools Used

- OpenAI Codex
- Claude Code

I used both tools throughout development for architecture planning, implementation, code review, and debugging. AI was used as an engineering assistant rather than as an autonomous developer.

## Architecture & Project Structure

- Used both Codex and Claude Code to explore a scalable and modular project structure.
- Prompts explicitly required industry best practices, testability, scalability, and Apple Human Interface Guidelines.
- Instructed AI to avoid large monolithic SwiftUI views and separate subviews into dedicated files.
- Reviewed both AI-generated approaches and made the final decisions on feature boundaries, number of views/subviews, and overall architecture.
- Used separate AI sessions for individual UI sections to keep implementations focused.

## Code Review & Corrections

AI-generated code was reviewed and tested rather than accepted directly.

Examples:

- **Concurrency.** Codex identified concurrency warnings but did not fully resolve them. I reviewed the code and fixed the remaining data-race issues manually.
- **RouteHeaderView.** Codex incorrectly aligned controls to the top instead of vertically centering them, and added unwanted outer padding that left white margins around the header. I identified and corrected both issues.
- **UI details.** Some specific requirements were missed even when stated explicitly. For example, the selected-day highlight in the date and fare strip was specified in both the prompt and the Figma frame, and still came back missing on the first pass. I provided more targeted prompts after reviewing the implementation and refined the output.
- **Empty state.** The first pass at the empty state dropped the date and fare strip from the layout entirely, causing the screen to jump between states instead of staying visually consistent. This wasn't caught by the tool on its own — I identified the inconsistency during review and gave a specific prompt describing the expected behavior before it was handled properly.

## Data & API Validation

- Used AI to generate data-fetching states and related boilerplate.
- Performed sanity testing using temporary logs to verify that data was actually being received and matched the expected format.
- **Currency.** The task brief suggests the following request, which uses `currency=BDT`:
  ```
  GET https://serpapi.com/search?engine=google_flights&departure_id=DAC&arrival_id=BKK&outbound_date=2026-02-15&type=2&currency=BDT&hl=en&api_key=YOUR_SERPAPI_KEY
  ```
  Running it returns a "Unsupported `BDT` for currency." error rather than flight results. I checked this against SerpApi's own supported currency list — [serpapi.com/google-travel-currencies](https://serpapi.com/google-travel-currencies) — and confirmed BDT isn't on it. The app requests USD instead and converts to BDT locally at a fixed rate before display and sorting, since the design and the date-fare strip are both specified in BDT. The rate is supplied at composition rather than hardcoded inside the mapper, so it stays a configuration value rather than a constant buried in mapping logic.

## Edge Cases & UI Behavior

The progress bar is a simulated, time-based animation. SerpApi's response carries no partial-progress signal — only a `total_time_taken` value that arrives after the request has already finished — so there is nothing real to bind it to. It is decorative, the same as the Filter button.

## My Role vs. AI's Role

AI contributed to:

- Architecture suggestions
- Code generation and boilerplate
- Subview implementation
- Initial state handling
- Identifying some issues
- Exploring implementation approaches

I was responsible for:

- Final architecture and technical decisions
- Reviewing and accepting/rejecting AI output
- UI/UX decisions
- API validation
- Testing and sanity checks
- Debugging and manual fixes
- Handling edge cases
- Final code quality and behavior

## Overall Approach

Requirement → AI-assisted planning → Human decision → AI implementation → Review/testing → Correction → Final implementation

AI accelerated development, but the final implementation was driven by review, engineering judgment and validation.

## Known Trade-offs & Current Status

- The Filter button and the Edit action are decorative, as the task allows.
- Date strip taps are ignored and its fares are hardcoded.
- Flight cards do not navigate anywhere; the Coordinator delegate carries the promotion tap, and Learn more is the only real navigation the screen has.
