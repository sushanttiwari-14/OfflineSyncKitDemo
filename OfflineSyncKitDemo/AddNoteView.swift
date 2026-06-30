//
//  AddNoteView.swift
//  OfflineSyncKitDemo
//  Created by sushant tiwari on 27/06/26.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""
    
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Note title", text: $title)
                }
                Section("Content") {
                    TextField("Note content", text: $content)
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(title, content)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
