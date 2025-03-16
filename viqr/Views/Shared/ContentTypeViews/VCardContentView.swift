//
//  VCardContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct VCardContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Contact Information")
                    .font(.headline)

                if case .vCard(
                    let firstName, let lastName, let organization, let title, let phone, let email,
                    let address, let website, let note) = content.data
                {
                    Text("Personal Details").font(.subheadline)

                    TextField(
                        "First Name",
                        text: Binding<String>(
                            get: { firstName },
                            set: { updateVCard(firstName: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(
                        "Last Name",
                        text: Binding<String>(
                            get: { lastName },
                            set: { updateVCard(lastName: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    // Professional Details Section
                    Text("Professional Details").font(.subheadline)
                        .padding(.top, 8)

                    TextField(
                        "Organization",
                        text: Binding<String>(
                            get: { organization },
                            set: { updateVCard(organization: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(
                        "Job Title",
                        text: Binding<String>(
                            get: { title },
                            set: { updateVCard(title: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    // Contact Details Section
                    Text("Contact Details").font(.subheadline)
                        .padding(.top, 8)

                    TextField(
                        "Phone Number",
                        text: Binding<String>(
                            get: { phone },
                            set: { updateVCard(phone: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                        .keyboardType(.phonePad)
                    #endif

                    TextField(
                        "Email",
                        text: Binding<String>(
                            get: { email },
                            set: { updateVCard(email: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                        .keyboardType(.emailAddress)
                    #endif

                    TextField(
                        "Address",
                        text: Binding<String>(
                            get: { address },
                            set: { updateVCard(address: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField(
                        "Website",
                        text: Binding<String>(
                            get: { website },
                            set: { updateVCard(website: $0) }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                        .keyboardType(.URL)
                    #endif

                    // Additional Information Section
                    Text("Additional Information").font(.subheadline)
                        .padding(.top, 8)

                    #if os(iOS)
                        TextEditor(
                            text: Binding<String>(
                                get: { note },
                                set: { updateVCard(note: $0) }
                            )
                        )
                        .frame(minHeight: 100)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    #else
                        TextEditor(
                            text: Binding<String>(
                                get: { note },
                                set: { updateVCard(note: $0) }
                            )
                        )
                        .frame(minHeight: 100)
                        .border(Color.gray.opacity(0.2), width: 1)
                    #endif
                }

                Text(
                    "Scanning this QR code will allow the user to save your contact information to their device."
                )
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 8)
            }
            .padding()
        }
        .padding()
        #if os(iOS)
            .background(Color.appSurface.opacity(0.5))
            .cornerRadius(10)
        #endif
    }

    // Helper method to update vCard fields while preserving other values
    private func updateVCard(
        firstName: String? = nil,
        lastName: String? = nil,
        organization: String? = nil,
        title: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        website: String? = nil,
        note: String? = nil
    ) {
        if case .vCard(
            let currFirstName, let currLastName, let currOrganization, let currTitle,
            let currPhone, let currEmail, let currAddress, let currWebsite, let currNote) = content
            .data
        {
            content.data = .vCard(
                firstName: firstName ?? currFirstName,
                lastName: lastName ?? currLastName,
                organization: organization ?? currOrganization,
                title: title ?? currTitle,
                phone: phone ?? currPhone,
                email: email ?? currEmail,
                address: address ?? currAddress,
                website: website ?? currWebsite,
                note: note ?? currNote
            )
        }
    }
}
