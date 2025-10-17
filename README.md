# MovieBrowser

A simple iOS app that searches **TMDB** for movies, supports pagination, offline fallback, and a Favorites list. Architecture uses **MVVM + Coordinator**, `URLSession`, and no external UI libraries. Includes **Unit Tests** and **UI Tests** (with a mock mode).

## Requirements
- **Xcode**: 15 or later (tested up to Xcode 16)
- **iOS**: 15.0+
- **Swift**: Concurrency enabled (Swift 5.7+ / Swift 6 compatible)
- **TMDB** API access token (Bearer)

## Project Structure
```
App/
  Coordinators/          // SearchCoordinator, navigation wiring
  Scenes/
    Search/              // SearchViewController, SearchViewModel
    Details/             // MovieDetailsViewController, MovieDetailsViewModel
  Models/                // Movie, MovieSearchResponse
  Networking/
    SearchAPI.swift      // URLSession-based API
    SearchAPIProtocol.swift
    Stubs/               // InMemorySearchAPIStub (used by UITests)
    NetworkClient
  Utilities/
    AppConfig.swift
    AppError.swift       // user-friendly errors
    ErrorMapper.swift    // map URL/HTTP errors -> AppError
    FavoriteStore        // add, remove and list Favorites
    MovieDateFormatter.swift
    SimpleCache.swift    // cached first page per query (if present)
  Support/
    Configs/
      Secrets.template.xcconfig  // template (no secrets tracked)
      Secrets.xcconfig           // your local secrets (ignored by git)
Tests/
  MovieBrowserTests/     // Unit tests: VMs, mappers, etc.
  MovieBrowserUITests/   // UI tests: search flow, favorites toggle
```

## Setup

### 1) Secrets / API token
1. Duplicate the template:
   ```bash
   cp App/Support/Configs/Secrets.template.xcconfig
   ```
2. Open `Secrets.template.xcconfig` and set:
   ```
   TMDB_ACCESS_TOKEN = your_tmdb_bearer_token_here
   ```
3. Ensure your target’s **Build Settings** imports the config (either directly or via the project’s `.xcconfig`). The app reads this value at runtime and injects it into `SearchAPI`.

> If the token is missing/invalid you’ll see a **401 Unauthorized** error surfaced as a friendly message in the UI.

### 2) Info.plist (optional)
If your project also mirrors the token in `Info.plist`, ensure the key exists:
- Key: `TMDBAccessToken`
- Value: `$(TMDB_ACCESS_TOKEN)`

## Build & Run

### Xcode (recommended)
1. Open the project in Xcode.
2. Select the **MovieBrowser** scheme.
3. Choose a simulator (e.g., iPhone).
4. **Run** (⌘R).

### Command line
```bash
xcodebuild   -scheme MovieBrowser   -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'   build
```

## Using the App
- Type in the search bar to search TMDB (e.g., “Jack Reacher”).  
- Scroll to paginate; a footer spinner appears while loading.  
- Tap a row to see **Details** (poster, title, date, overview).  
- Tap the **Save** / **Saved** (Favorites are persisted via `UserDefaults`and survive app restarts).  
- Offline:
  - If page 1 fails and a cached page exists for that query, the app shows the last saved results and a banner message.

## Tests

### Unit Tests
- **Run**: ⌘U (Product ▸ Test)  
- What they cover:
  - `SearchViewModel`: first page load, pagination appends, offline fallback

### UI Tests (with mock mode)
The app switches to a deterministic stub when launched with `UITEST_MODE`.

**SceneDelegate/AppDelegate wiring:**
```swift
let isUITest = ProcessInfo.processInfo.arguments.contains("UITEST_MODE")
let searchAPI: SearchAPIProtocol = isUITest ? InMemorySearchAPIStub()
                                            : SearchAPI(accessToken: AppConfig.tmdbAccessToken)
let coordinator = SearchCoordinator(navigationController: nav, searchAPI: searchAPI)
```

**UI test setup:**
```swift
let app = XCUIApplication()
app.launchArguments.append("UITEST_MODE")
app.launch()
```

What they cover:
- Search flow (type query → see results → open details)  

## Architecture Notes
- **Coordinator** starts the Search scene and handles navigation to Details
- **ViewModels (@MainActor)** expose outputs via closures: `onMoviesChanged`, `onError`, `onInfo`.
- **Networking** uses `URLSession`. Responses are validated (2xx) before decoding.
  ```swift
  guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
      throw mapToAppError(URLError(.badServerResponse), response: response as? HTTPURLResponse)
  }
  ```
- **Error handling**: errors (offline, server), alerts for blockers (401), and an empty state for no results.
- **Favorites**: stored as JSON in `UserDefaults`. If your `Movie` is `Decodable`, add:
  ```swift
  extension Movie: Encodable {}
  ```

## Troubleshooting
- **UI Tests can’t find search**: set `searchBar.searchTextField.accessibilityIdentifier = "search.searchField"` and use that ID in tests.
- **Ambiguous Auto Layout**: in the details ScrollView, content view width must equal the scroll view’s Frame Layout Guide; avoid fixed widths on content/stack.

## License
Educational/demo purposes.
