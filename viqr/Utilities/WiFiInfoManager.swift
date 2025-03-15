//
//  WiFiInfoManager.swift
//  viqr
//
//  Created on 15/3/25.
//

import Foundation
import CoreLocation

#if os(iOS)
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
#elseif os(macOS)
import CoreWLAN
#endif

class WiFiInfoManager: NSObject, ObservableObject {
    @Published var currentSSID: String?
    @Published var isLoading: Bool = false

    #if os(iOS)
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestWiFiInfo() {
        isLoading = true

        // Request authorization - this will trigger the delegate callback
        // where we'll check the status and fetch SSID if authorized
        locationManager.requestWhenInUseAuthorization()

        // Start a timeout timer in case something goes wrong
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            if self?.isLoading == true {
                self?.isLoading = false
            }
        }
    }

    private func fetchSSID() {
        if #available(iOS 14.0, *) {
            // Set a timeout to ensure we don't get stuck waiting
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                if self?.isLoading == true {
                    // If still loading after timeout, cancel the operation
                    self?.isLoading = false
                    self?.locationManager.stopUpdatingLocation()
                }
            }

            // Try to fetch the current hotspot
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    if let ssid = network?.ssid {
                        self.currentSSID = ssid
                    } else if #available(iOS 15.0, *) {
                        // Try alternative method for iOS 15+
                        self.fetchSSIDAlternative()
                        return
                    }

                    self.isLoading = false
                    self.locationManager.stopUpdatingLocation()
                }
            }
        } else {
            // For older iOS versions
            self.isLoading = false
            self.currentSSID = nil
            self.locationManager.stopUpdatingLocation()
        }
    }

    // Alternative SSID fetching method for iOS 15+
    @available(iOS 15.0, *)
    private func fetchSSIDAlternative() {
        // This uses a private API that might be more reliable on iOS 15+
        // But we'll need to carefully handle any potential issues
        do {
            if let interfaceNames = CFBridgingRetain(CNCopySupportedInterfaces()) as? [String] {
                for name in interfaceNames {
                    if let info = CFBridgingRetain(CNCopyCurrentNetworkInfo(name as CFString)) as? [String: Any],
                       let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                        DispatchQueue.main.async {
                            self.currentSSID = ssid
                            self.isLoading = false
                            self.locationManager.stopUpdatingLocation()
                        }
                        return
                    }
                }
            }
        }

        // If we get here, we couldn't get the SSID
        DispatchQueue.main.async {
            self.currentSSID = nil
            self.isLoading = false
            self.locationManager.stopUpdatingLocation()
        }
    }
    #elseif os(macOS)
    func requestWiFiInfo() {
        isLoading = true
        fetchSSID()
    }

    private func fetchSSID() {
        if let interface = CWWiFiClient.shared().interface() {
            do {
                self.currentSSID = try interface.ssid()
            } catch {
                print("Error getting SSID: \(error)")
                self.currentSSID = nil
            }
        } else {
            self.currentSSID = nil
        }
        self.isLoading = false
    }
    #endif
}

#if os(iOS)
extension WiFiInfoManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        // Process authorization status in the delegate method
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Location services are authorized, proceed with fetching SSID
            manager.startUpdatingLocation() // Activate location services
            fetchSSID()

        case .denied, .restricted:
            // User denied location permission
            DispatchQueue.main.async {
                self.isLoading = false
                self.currentSSID = nil
            }

        case .notDetermined:
            // Wait for user decision
            break

        @unknown default:
            // Handle future authorization states
            DispatchQueue.main.async {
                self.isLoading = false
                self.currentSSID = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.currentSSID = nil
        }
        print("Location manager error: \(error)")
    }
}
#endif
