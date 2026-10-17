import CoreLocation
import MapKit
import SwiftUI

struct FencesView: View {
    @Environment(DogStore.self) private var store
    @State private var editing: Fence?

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            List {
                if store.fences.isEmpty {
                    ContentUnavailableView("No fences yet", systemImage: "square.dashed",
                                           description: Text("Add a fence and Doggo will cue your dog when they leave it."))
                }
                ForEach($store.fences) { $fence in
                    HStack {
                        Button { editing = fence } label: {
                            VStack(alignment: .leading) {
                                Text(fence.name).foregroundStyle(.primary)
                                Text("\(Int(fence.radiusMeters)) m • \(fence.boundaryFeedback.label) when leaving")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.borderless)
                        Spacer()
                        Toggle("On", isOn: $fence.isEnabled).labelsHidden()
                    }
                }
                .onDelete { store.fences.remove(atOffsets: $0) }
            }
            .navigationTitle("Fences")
            .toolbar {
                Button("Add fence", systemImage: "plus") {
                    editing = Fence(name: "New fence", center: defaultCenter)
                }
            }
            .sheet(item: $editing) { fence in
                FenceEditorView(fence: fence) { store.save($0) }
            }
        }
    }

    /// Start a new fence where a dog is, so it lands somewhere useful.
    private var defaultCenter: CLLocationCoordinate2D {
        store.dogs.compactMap(\.location).first ?? CLLocationCoordinate2D(latitude: 27.9506, longitude: -82.4572)
    }
}

struct FenceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fence: Fence
    @State private var camera: MapCameraPosition
    let onSave: (Fence) -> Void

    init(fence: Fence, onSave: @escaping (Fence) -> Void) {
        _fence = State(initialValue: fence)
        _camera = State(initialValue: .region(MKCoordinateRegion(
            center: fence.coordinate, latitudinalMeters: fence.radiusMeters * 5, longitudinalMeters: fence.radiusMeters * 5)))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MapReader { proxy in
                        Map(position: $camera) {
                            UserAnnotation()
                            MapCircle(center: fence.coordinate, radius: fence.radiusMeters)
                                .foregroundStyle(.green.opacity(0.2))
                                .stroke(.green, lineWidth: 2)
                        }
                        .onTapGesture { point in
                            if let coordinate = proxy.convert(point, from: .local) {
                                fence.coordinate = coordinate
                            }
                        }
                    }
                    .frame(height: 280)
                    .listRowInsets(EdgeInsets())
                } footer: {
                    Text("Tap the map to move the fence's center.")
                }
                Section {
                    TextField("Name", text: $fence.name)
                    VStack(alignment: .leading) {
                        Text("Size: \(Int(fence.radiusMeters)) m around the center")
                        Slider(value: $fence.radiusMeters, in: 10...300, step: 5)
                    }
                    Picker("When your dog leaves", selection: $fence.boundaryFeedback) {
                        ForEach(BoundaryFeedback.allCases, id: \.self) { Text($0.label) }
                    }
                    Toggle("Fence on", isOn: $fence.isEnabled)
                } footer: {
                    Text("Doggo cues the collar once when your dog walks out, then waits before cueing again. Static is never used for fences.")
                }
            }
            .navigationTitle(fence.name.isEmpty ? "Fence" : fence.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(fence)
                        dismiss()
                    }
                    .disabled(fence.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
