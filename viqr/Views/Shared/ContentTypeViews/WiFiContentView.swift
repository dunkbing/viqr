//
//  WiFiContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import CoreLocation

struct WiFiContentView: View {
    @Binding var content: QRCodeContent
    @State private var isPasswordVisible = false
    @StateObject private var wifiManager = WiFiInfoManager()
    @State private var showLocationPermissionAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wi-Fi Network Details")
                .font(.headline)

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
                        ))

                    HStack {
                        Text("Security")
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
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    if security != .nopass {
                        HStack {
                            if isPasswordVisible {
                                TextField(
                                    "Password",
                                    text: Binding<String>(
                                        get: { password },
                                        set: { newValue in
                                            content.data = .wifi(
                                                ssid: ssid, password: newValue, isHidden: isHidden,
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
                                                ssid: ssid, password: newValue, isHidden: isHidden,
                                                security: security)
                                        }
                                    )
                                )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // Loading indicator
                    if wifiManager.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())

                            Text("Retrieving WiFi information...")
                                .foregroundColor(.gray)
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
            .foregroundColor(.gray)

            #if os(iOS)
            Text("Note: Loading current WiFi requires location permission.")
                .font(.caption)
                .foregroundColor(.orange)
            #endif
        }
        .padding()
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
        .alert(isPresented: $showLocationPermissionAlert) {
            Alert(
                title: Text("Location Permission Needed"),
                message: Text("To detect the current WiFi network, location access is required."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}
