import MapKit
import SwiftUI

struct DogMapView: View {
    @Environment(DogStore.self) private var store
    @State private var camera: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $camera) {
            UserAnnotation()
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
        .overlay(alignment: .bottom) {
            if store.dogs.isEmpty {
                Text("No collars connected yet")
                    .padding()
                    .background(.thinMaterial, in: Capsule())
                    .padding()
            }
        }
    }
}
