import SwiftUI

@main
struct DoggoApp: App {
    @State private var store = DogStore(providers: [
        MockCollarProvider(),
        HaloCollarProvider(),
        GuardianCollarProvider(),
    ])

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .task { await store.startPolling() }
        }
    }
}
