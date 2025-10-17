# Build Decisions, Challenges & What I Learned

## Architecture
- **Pattern:** MVVM + Coordinator.  
  - **Why:** Keeps view controllers lean, testable logic in ViewModels, and navigation isolated in a Coordinator.
- **DI (Dependency Injection):** `SearchAPIProtocol` passed into the `SearchCoordinator`.  
  - **Why:** Enables swapping real/stub services (unit & UI tests), improves testability and separation of concerns.
- **Concurrency:** Swift concurrency (`async/await`) with `@MainActor` ViewModels.  
  - **Why:** Clear threading semantics, avoids UI updates off main thread.

## Networking
- **Stack:** `URLSession` + `Decodable` (snake_case strategy).  
  - **Why (vs Moya/ObjectMapper):** Keep dependencies minimal, easier for reviewers to read; Swift Codable handles TMDB cleanly.
- **HTTP Validation:** Non-2xx statuses are checked before decoding (small helper).  
  - **Why:** Avoids confusing “decoding failed” when the real cause is 401/404/5xx; maps to friendly `AppError` messages.

## Configuration / Secrets
- **`.xcconfig` + Info.plist bridge:** `TMDB_ACCESS_TOKEN` is defined in `Secrets.xcconfig` (git-ignored) and read at runtime.  
  - **Why:** Keeps secrets out of source control; simple for reviewers to set up.
- **Mock mode for tests/demos:** The app can launch with `UITEST_MODE` and uses `InMemorySearchAPIStub`.  
  - **Why:** Deterministic UI tests, easy demo without a token or network.

## UI & UX
- **Search Screen:** `UISearchBar` + `UITableView`, minimal cell with poster, title, date, and a favorites heart (SF Symbols).  
  - **Why:** Clean, fast to scan, works with built-in assets.
- **Details Screen:** XIB with `UIScrollView` → Content View → Vertical `UIStackView` (poster, title, date, overview).  
  - **Why:** Simple, scalable layout; stack view makes dynamic content easy.  
- **Error Feedback:** 
  - Banners for soft issues (offline, server hiccups).  
  - Alerts for blockers (e.g., 401 authorization).  
  - Empty state label for “no results”.

## Data
- **Model:** Trimmed `Movie` to only fields used (`id, title, overview, releaseDate, posterPath`).  
  - **Why:** Simpler code & tests; extra TMDB fields decode automatically if added back later.
- **Pagination:** ViewModel tracks `currentPage`, `totalPages`, `isLoading`.  
  - **Why:** Prevents double loads; explicit page math; safe in rapid scrolling.
- **Caching (lightweight):** 
  - URL-level caching via `URLCache` (benefits repeated queries naturally).  
  - Optional first-page persistence (SimpleCache) for offline “last results” message.  
  - **Why:** Enough resilience without heavy storage.

## Favorites
- **Persistence:** `UserDefaults` storing `Movie` as JSON (made `Movie` `Codable`).  
  - **Why:** Zero-dependency, survives relaunch, simple to reason about.
- **UI:** Heart button uses `heart` / `heart.fill`; `.tertiaryLabel` when off, `.systemRed` (or white over poster) when on.  
  - **Why:** Clear, accessible, and native look without custom assets.

## Testing
- **Unit Tests:** 
  - Stubs: `StubSearchAPI` + `TestData.movie/page`.  
  - Covered: initial search, pagination append, offline fallback, details formatting, error mapping.
- **UI Tests:** 
  - Launch with `UITEST_MODE`, accessibility identifiers for search field/table/cell controls.  
  - Covered: search flow (type → results → open details), favorite toggle.  
  - **Why:** Reliable, network-free runs; IDs make tests resilient to text/locale changes.

## Notable Challenges & Fixes
- **Search bar wasn’t found in UI tests:**  
  - **Issue:** Tests looked for the bar, but `UISearchBar` exposes a **search text field** element.  
  - **Fix:** Set `searchBar.searchTextField.accessibilityIdentifier = "search.searchField"` and targeted that in tests.
- **ScrollView layout warnings / narrow content:**  
  - **Issue:** Ambiguous content size and width constraints.  
  - **Fix:** Pinned Content View to **Content Layout Guide** on all sides, set **Content.width == Frame Layout Guide.width**, then added a vertical stack with intrinsic height. No fixed widths on content/stack.
- **Main thread checker crashes:**  
  - **Issue:** UI updated off the main thread.  
  - **Fix:** Marked ViewModels `@MainActor` and ensured UI callbacks run on main.
- **Throw/catch mismatch:**  
  - **Issue:** `search()` tried `try/await` on a non-throwing loader.  
  - **Fix:** Either removed `try/catch` or made the loader throw and centralize mapping via `AppError`.
- **Auth clarity / missing token confusion:**  
  - **Issue:** App “seemed to work” without local secrets (stub/cached data).  
  - **Fix:** Added clear README steps; optional `assert` when no token and not in `UITEST_MODE`.

