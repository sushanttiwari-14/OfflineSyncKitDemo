//
//  ContentView.swift
//  OfflineSyncKitDemo
//
//  Created by sushant tiwari on 26/06/26.
//

import SwiftUI
import OfflineSyncKit

struct ContentView: View {
    @StateObject private var appSetup = AppSetup()
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // sync status bar
                syncStatusBar
                
                // notes list
                List {
                    ForEach(notes, id: \.id) { note in
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteNote)
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(onSave: { title, content in
                    addNote(title: title, content: content)
                })
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    // sync status indicator
    var syncStatusBar: some View {
        HStack {
            switch appSetup.syncState {
            case .idle:
                Image(systemName: "checkmark.circle")
                Text("Up to date")
            case .syncing:
                ProgressView()
                Text("Syncing...")
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Sync complete")
            case .failed:
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                Text("Sync failed")
            }
        }
        .font(.caption)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
    
    func loadNotes() {
        notes = (try? appSetup.storage.fetchAll()) ?? []
    }
    
    func addNote(title: String, content: String) {
        let note = Note(title: title, content: content)
        try? appSetup.storage.save(note)
        
        // queue sync operation
        let operation = SyncOperation(noteId: note.id, type: .create)
        try? appSetup.queue.enqueue(operation)
        
        loadNotes()
    }
    
    func deleteNote(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            try? appSetup.storage.delete(note)
            
            // queue sync operation
            let operation = SyncOperation(noteId: note.id, type: .delete)
            try? appSetup.queue.enqueue(operation)
        }
        loadNotes()
    }
}
