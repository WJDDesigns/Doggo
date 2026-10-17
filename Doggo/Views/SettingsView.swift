import SwiftUI

struct SettingsView: View {
    @Environment(DogStore.self) private var store

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
                Section {
                    Toggle("Allow static correction", isOn: $store.safety.staticEnabled)
                    Stepper("Max level \(store.safety.maxStaticLevel)", value: $store.safety.maxStaticLevel, in: 1...15)
                    Stepper("Cooldown \(Int(store.safety.cooldownSeconds)) s", value: $store.safety.cooldownSeconds, in: 5...120, step: 5)
                } header: {
                    Text("Static")
                } footer: {
                    Text("Tone and vibrate always work. Static is off until you turn it on.")
                }
                Section {
                    Stepper("Cue cooldown \(Int(store.boundaryCooldownSeconds)) s", value: $store.boundaryCooldownSeconds,
                            in: 10...300, step: 10)
                } header: {
                    Text("Fences")
                } footer: {
                    Text("How long Doggo waits before cueing the same dog again after it leaves a fence.")
                }
                Section("Collars") {
                    LabeledContent("Halo One", value: "Not connected")
                    LabeledContent("PetSafe Guardian GPS 2.0", value: "Not connected")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
