//
//  AddWishlistView.swift
//  gwish
//
//  Created by Connie Zhu on 3/15/25.
//

import SwiftUI
import FirebaseCore

struct AddWishlistView: View {
    @ObservedObject var viewModel: WishlistViewModel
    @State private var wishlistTitle = ""
    @State private var addItem = false // Toggle for showing item input
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var selectedPriority: Priority = .none

    var body: some View {
        VStack(spacing: 20) {
            Text("New Wishlist")
                .font(.title2)
                .bold()

            TextField("Enter wishlist title", text: $wishlistTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Toggle("Add an item", isOn: $addItem)
                .padding()

            if addItem {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Item name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Item price (optional)", text: $itemPrice)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)

                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
            }

            HStack {
                Button("Cancel") {
                    viewModel.isAddingWishlist = false
                }
                .padding()
                .foregroundColor(.red)

                Spacer()

                Button("Save") {
                    var newItem: Item? = nil
                    if addItem, !itemName.isEmpty {
                        newItem = Item(
                            name: itemName,
                            price: Double(itemPrice),
                            priority: selectedPriority == .none ? nil : selectedPriority,
                            url: nil,
                            location: nil,
                            creationDate: Timestamp(date: Date()),
                            category: nil,
                            occasion: nil,
                            status: nil
                        )
                    }
                    viewModel.createWishlist(title: wishlistTitle, initialItem: newItem)
                }
                .padding()
                .disabled(wishlistTitle.isEmpty)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
        .padding()
    }
}
