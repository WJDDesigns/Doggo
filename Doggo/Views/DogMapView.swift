import MapKit
import SwiftUI

struct DogMapView: View {
    @Environment(DogStore.self) private var store
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $camera) {
            UserAnnotation()
            ForEach(store.fences) { fence in
                MapCircle(center: fence.coordinate, radius: fence.radiusMeters)
                    .foregroundStyle((fence.isEnabled ? Color.green : Color.gray).opacity(0.2))
                    .stroke(fence.isEnabled ? Color.green : Color.gray, lineWidth: 2)
            }
            ForEach(store.dogs) { dog in
                if let location = dog.location {
                    Annotation(dog.name, coordinate: location) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white, dog.brand == .halo ? .orange : .blue)
                    }
                }
            }
        }
        .mapControls { MapUserLocationButton() }
        .safeAreaInset(edge: .bottom) {
            if store.dogs.isEmpty {
                Text("No collars connected yet")
                    .padding()
                    .background(.thinMaterial, in: Capsule())
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(store.dogs) { dog in
                            DogCard(dog: dog, zone: store.zoneLine(for: dog))
                                .onTapGesture { focus(on: dog) }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func focus(on dog: Dog) {
        guard let location = dog.location else { return }
        withAnimation {
            camera = .region(MKCoordinateRegion(center: location, latitudinalMeters: 250, longitudinalMeters: 250))
        }
    }
}

/// The pet card under the map: where the dog is, GPS quality and battery, as in the PetSafe Pets panel.
struct DogCard: View {
    let dog: Dog
    let zone: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dog.name).font(.headline)
            Text(zone).font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                if let gps = dog.gpsSignal {
                    Label("GPS \(gps.rawValue)", systemImage: "location.fill")
                        .foregroundStyle(gps == .poor ? Color.orange : Color.primary)
                }
                if let battery = dog.batteryPercent {
                    Label(dog.isCharging ? "Charging \(battery)%" : "\(battery)%", systemImage: batteryIcon(battery))
                        .foregroundStyle(battery <= 15 && !dog.isCharging ? Color.red : Color.primary)
                }
            }
            .font(.caption)
        }
        .padding()
        .frame(minWidth: 200, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func batteryIcon(_ percent: Int) -> String {
        if dog.isCharging { return "battery.100percent.bolt" }
        switch percent {
        case ..<13: return "battery.0percent"
        case ..<38: return "battery.25percent"
        case ..<63: return "battery.50percent"
        case ..<88: return "battery.75percent"
        default: return "battery.100percent"
        }
    }
}
