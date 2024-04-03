// © Agni Ilango
// SPDX-License-Identifier: MPL-2.0

import Combine
import CoreLocation
import Dependencies
import DependenciesMacros
import Foundation

private class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    private let locationsPublisher = PassthroughSubject<[CLLocation], Never>()
    private let headingPublisher = PassthroughSubject<CLHeading, Never>()
    private var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()
        manager.delegate = self
    }

    public var headings: AsyncStream<CLHeading> {
        AsyncStream { continuation in
            let subscription = headingPublisher.sink { heading in
                continuation.yield(heading)
            }

            continuation.onTermination = { _ in
                subscription.cancel()
            }
        }
    }

    public var locations: AsyncStream<[CLLocation]> {
        AsyncStream { continuation in
            let subscription = locationsPublisher.sink { location in
                continuation.yield(location)
            }

            continuation.onTermination = { _ in
                subscription.cancel()
            }
        }
    }

    public func start() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingHeading()
        manager.startUpdatingLocation()
    }

    @MainActor public func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingPublisher.send(newHeading)
    }

    public func locationManager(
        _: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        locationsPublisher.send(locations)
    }
}

@DependencyClient
public struct LocationClient {
    private let locationFetcher = LocationFetcher()

    public var headings: AsyncStream<CLHeading> {
        locationFetcher.headings
    }

    public var locations: AsyncStream<[CLLocation]> {
        locationFetcher.locations
    }

    public init() {}

    public func start() {
        locationFetcher.start()
    }

    public func getLocality(location: CLLocation) async -> String? {
        let geocoder = CLGeocoder()
        let placemark = try? await geocoder.reverseGeocodeLocation(location)
        return placemark?[0].locality
    }
}

extension LocationClient: DependencyKey {
    public static let liveValue = Self()
}

extension LocationClient: TestDependencyKey {
    public static let previewValue = Self()
    public static let testValue = Self()
}

public extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}
