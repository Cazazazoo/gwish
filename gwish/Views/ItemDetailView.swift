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

struct ItemDetailView: View {
    var item: ItemDraft // Keep for revert or reset details one day
    // Copy
    @State private var draft: ItemDraft

    @Environment(\.dismiss) var dismiss
    var mode: ItemDetailMode = .add
    
    var onDone: ((ItemDraft) -> Void)? = nil
    var onDelete: ((ItemDraft) -> Void)? = nil
    
    init(item: ItemDraft, mode: ItemDetailMode = .add, onDone: ((ItemDraft) -> Void)? = nil, onDelete: ((ItemDraft) -> Void)? = nil) {
        self.item = item
        self.mode = mode
        self._draft = State(initialValue: item)
        self.onDone = onDone
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Item Details")
                .font(.title2).bold()

            Group {
                TextField("Name", text: $draft.name)
                TextField("Price", text: $draft.price)
                    .keyboardType(.decimalPad) // TODO: not sure if i like this format

                Picker("Priority", selection: $draft.priority) {
                    ForEach(Priority.allCases, id: \.self) {
                        Text($0.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Link", text: $draft.link)
                TextField("Location", text: $draft.location)
                TextField("Category", text: $draft.category)
                TextField("Occasion", text: $draft.occasion)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Spacer()

            if mode == .edit {
                HStack {
                    Button(draft.complete ? "Mark Incomplete" : "Mark Complete") {
                        draft.complete.toggle()
                    }
                    .foregroundColor(draft.complete ? .orange : .green)

                    Spacer()

                    Button("Delete") {
                        onDelete?(draft)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                .padding(.vertical)
            }

            Button("Done") {
                onDone?(draft)
                dismiss()
            }
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
}
