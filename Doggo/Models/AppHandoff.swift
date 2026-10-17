import Foundation

/// A collar Doggo can't command directly, so it hands off to the maker's own app.
/// Used for Halo, which has no public API: Doggo opens the app and you press Instant Feedback there.
struct AppHandoff: Hashable {
    var appName: String
    /// The app's URL scheme, tried first.
    var scheme: URL
    /// App Store page, opened if the app isn't installed.
    var appStore: URL
    var note: String

    static let halo = AppHandoff(
        appName: "Halo",
        scheme: URL(string: "halo://")!,
        appStore: URL(string: "https://apps.apple.com/app/id1476830649")!,
        note: "Halo has no public API, so Doggo opens the Halo app. Press Instant Feedback there to beep or buzz Cooper.")
}
