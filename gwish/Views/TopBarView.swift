//
//  TopBarView.swift
//  gwish
//
//  Created by Connie Zhu on 4/25/25.
//

import SwiftUI

struct TopBarView: View {
    let onProfileTap: () -> Void
    let onFilterTap: () -> Void
    let title: String

    var body: some View {
        HStack {
            Button(action: onProfileTap) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.leading)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text(title)
                .font(.title2)
                .fontWeight(.medium)

            Spacer()

            Button(action: onFilterTap) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .padding(.trailing)
            }
        }
        .padding(.vertical)
//        .padding(.top, 10)
    }
}
