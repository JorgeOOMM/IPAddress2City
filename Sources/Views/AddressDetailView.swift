//
//  AddressDetailView.swift
//  IPRanges
//
//  Created by Mac on 14/12/25.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: MapLocation
struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

extension CLLocationCoordinate2D {
    static let newYork: Self = .init(
        latitude: 40.730610,
        longitude: -73.935242
    )
}
// MARK: AddressDetailView
struct AddressDetailView: View {
    let address: AddressElement
    @State private var location = MapLocation(name: "New York", coordinate: .newYork)
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: .newYork,
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var body: some View {
        VStack {
            Divider()
            Text(address.address)
            Text(address.start)
            Text(address.end)
            HStack {
                Text(address.country)
                Text(address.flag)
            }
            Text(address.subdiv)
            Divider()
            Map(position: $position, interactionModes: .all) {
                Marker(coordinate: location.coordinate) {
                    Label(location.name, systemImage: "mappin")
                }
            }
        }
        .onAppear {
            CLGeocoder().geocodeAddressString(address.locationName) { placemarks, error in
                if let error = error {
                    print(error)
                }
                if let placemark = placemarks?.first {
                    if let location = placemark.location {
                        self.location = MapLocation(
                            name: address.locationName,
                            coordinate: location.coordinate
                        )
                        self.position = MapCameraPosition.region(
                            MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                            )
                        )
                    }
                }
            }
        }
    }
}
