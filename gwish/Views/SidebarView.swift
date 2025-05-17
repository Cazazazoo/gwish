//
//  SidebarView.swift
//  gwish
//
//  Created by Connie Zhu on 4/25/25.
//

import SwiftUI

struct SidebarView: View {
    let onSelect: (SidebarOption) -> Void
    let onLogout: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.top, 40)

            ForEach(SidebarOption.allCases, id: \.self) { option in
                Button(action: {
                    onSelect(option)
                }) {
                    Text(option.rawValue)
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                }
            }

            Divider().padding(.vertical, 10)

            Button("Logout", action: onLogout)
                .foregroundColor(.red)
                .padding(.vertical, 10)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
    }
}

enum SidebarOption: String, CaseIterable {
//    case home = "Home"
    case wishlists = "Wishlists"
    case profiles = "Profiles"
}

