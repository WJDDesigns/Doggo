import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DogMapView()
                .tabItem { Label("Map", systemImage: "map") }
            CommandsView()
                .tabItem { Label("Commands", systemImage: "dot.radiowaves.left.and.right") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
