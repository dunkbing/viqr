//
//  WiFiContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import CoreLocation
import SwiftUI

struct WiFiContentView: View {
    @Binding var content: QRCodeContent
    @State private var isPasswordVisible = false
    @StateObject private var wifiManager = WiFiInfoManager()
    @State private var showLocationPermissionAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wi-Fi Network Details")
                .font(.headline)
                .foregroundColor(Color.appText)

            if case .wifi(let ssid, let password, let isHidden, let security) = content.data {
                Group {
                    HStack {
                        TextField(
                            "Network Name (SSID)",
                            text: Binding(
                                get: { ssid },
                                set: { newValue in
                                    content.data = .wifi(
                                        ssid: newValue, password: password, isHidden: isHidden,
                                        security: security)
                                }
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disableAutocorrection(true)
                        .foregroundColor(Color.appText)

                        Button(action: {
                            #if os(iOS)
                                let status = CLLocationManager().authorizationStatus
                                if status == .denied || status == .restricted {
                                    showLocationPermissionAlert = true
                                } else {
                                    wifiManager.requestWiFiInfo()
                                }
                            #else
                                wifiManager.requestWiFiInfo()
                            #endif
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color.appAccent)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .help("Load current WiFi SSID")
                    }

                    Toggle(
                        "Hidden Network",
                        isOn: Binding(
                            get: { isHidden },
                            set: { newValue in
                                content.data = .wifi(
                                    ssid: ssid, password: password, isHidden: newValue,
                                    security: security)
                            }
                        )
                    )
                    .foregroundColor(Color.appText)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Security")
                            .foregroundColor(Color.appText)

                        Picker(
                            "",
                            selection: Binding(
                                get: { security },
                                set: { newValue in
                                    content.data = .wifi(
                                        ssid: ssid, password: password, isHidden: isHidden,
                                        security: newValue)
                                }
                            )
                        ) {
                            ForEach(WiFiSecurity.allCases, id: \.self) { securityType in
                                Text(securityType.description).tag(securityType)
                                    .foregroundColor(Color.appText)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accentColor(Color.appAccent)
                    }

                    if security != .nopass {
                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField(
                                        "Password",
                                        text: Binding<String>(
                                            get: { password },
                                            set: { newValue in
                                                content.data = .wifi(
                                                    ssid: ssid, password: newValue,
                                                    isHidden: isHidden,
                                                    security: security)
                                            }
                                        )
                                    )
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                } else {
                                    SecureField(
                                        "Password",
                                        text: Binding<String>(
                                            get: { password },
                                            set: { newValue in
                                                content.data = .wifi(
                                                    ssid: ssid, password: newValue,
                                                    isHidden: isHidden,
                                                    security: security)
                                            }
                                        )
                                    )
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .foregroundColor(Color.appText)

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(Color.appSubtitle)
                                    .padding(8)
                                    .background(Color.appSurface2.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }

                    // Loading indicator
                    if wifiManager.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())

                            Text("Retrieving WiFi information...")
                                .foregroundColor(Color.appSubtitle)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Text(
                "When scanned, this QR code will allow devices to connect to this Wi-Fi network without typing the password."
            )
            .font(.caption)
            .foregroundColor(Color.appSubtitle)
            .padding(.top, 8)

            #if os(iOS)
                Text("Note: Loading current WiFi requires location permission.")
                    .font(.caption)
                    .foregroundColor(Color.appOrange)
            #endif
        }
        .padding()
        .background(Color.appSurface.opacity(0.5))
        .cornerRadius(10)
        .onChange(of: wifiManager.currentSSID) { newSSID in
            if let newSSID = newSSID {
                if case .wifi(_, let password, let isHidden, let security) = content.data {
                    content.data = .wifi(
                        ssid: newSSID,
                        password: password,
                        isHidden: isHidden,
                        security: security
                    )
                }
            }
        }
        #if os(iOS)
            .alert(isPresented: $showLocationPermissionAlert) {
                Alert(
                    title: Text("Location Permission Needed"),
                    message: Text(
                        "To detect the current WiFi network, location access is required."),
                    primaryButton: .default(
                        Text("Settings"),
                        action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }),
                    secondaryButton: .cancel()
                )
            }
        #endif
    }
}
