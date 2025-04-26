//
//  ItemDetailView.swift
//  gwish
//
//  Created by Connie Zhu on 4/26/25.
//

import SwiftUI

enum ItemDetailMode {
    case add, edit
}

struct ItemDraft {
    var name = ""
    var price = ""
    var priority: Priority = .none
    var location = "" // Probably leave as string
    // TODO: these item descriptors following my model
    var link = ""
    var category = ""
    var occasion = ""
}

struct ItemDetailView: View {
    @Binding var item: ItemDraft
    @Environment(\.dismiss) var dismiss
    var mode: ItemDetailMode = .add
    var onDelete: (() -> Void)? = nil // TODO: delete and complete
    var onComplete: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Item Details")
                .font(.title2).bold()

            Group {
                TextField("Name", text: $item.name)
                TextField("Price", text: $item.price)
                    .keyboardType(.decimalPad)

                Picker("Priority", selection: $item.priority) {
                    ForEach(Priority.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Link", text: $item.link)
                TextField("Location", text: $item.location)
                TextField("Category", text: $item.category)
                TextField("Occasion", text: $item.occasion)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Spacer()

            if mode == .edit {
                HStack {
                    Button("Complete") {
                        onComplete?()
                    }

                    Spacer()

                    Button("Delete") {
                        onDelete?()
                    }
                    .foregroundColor(.red)
                }
                .padding(.vertical)
            }

            Button("Done") {
                dismiss()
            }
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
}
