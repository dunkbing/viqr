//
//  WiFiContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct WiFiContentView: View {
    @Binding var content: QRCodeContent
    @State private var isPasswordVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Wi-Fi Network Details")
                .font(.headline)

            if case .wifi(let ssid, let password, let isHidden, let security) = content.data {
                Group {
                    TextField("Network Name (SSID)", text: Binding(
                        get: { ssid },
                        set: { newValue in
                            content.data = .wifi(ssid: newValue, password: password, isHidden: isHidden, security: security)
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    // .autocapitalization(.none)

                    Toggle("Hidden Network", isOn: Binding(
                        get: { isHidden },
                        set: { newValue in
                            content.data = .wifi(ssid: ssid, password: password, isHidden: newValue, security: security)
                        }
                    ))

                    HStack {
                        Text("Security")
                        Picker("", selection: Binding(
                            get: { security },
                            set: { newValue in
                                content.data = .wifi(ssid: ssid, password: password, isHidden: isHidden, security: newValue)
                            }
                        )) {
                            ForEach(WiFiSecurity.allCases, id: \.self) { securityType in
                                Text(securityType.description).tag(securityType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    if security != .nopass {
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: Binding<String>(
                                    get: { password },
                                    set: { newValue in
                                        content.data = .wifi(ssid: ssid, password: newValue, isHidden: isHidden, security: security)
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                // .autocapitalization(.none)
                                .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: Binding<String>(
                                    get: { password },
                                    set: { newValue in
                                        content.data = .wifi(ssid: ssid, password: newValue, isHidden: isHidden, security: security)
                                    }
                                ))
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
                }
            }

            Text("When scanned, this QR code will allow devices to connect to this Wi-Fi network without typing the password.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
