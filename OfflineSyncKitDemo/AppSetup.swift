//
//  AppSetup.swift
//  OfflineSyncKitDemo
//
//  Created by sushant tiwari on 26/06/26.
//

import SwiftUI
import SwiftData
import Combine
import OfflineSyncKit

@MainActor
class AppSetup: ObservableObject {
    let container: ModelContainer
    let storage: SwiftDataNoteStorage
    let queue: SyncQueue
    let syncManager: SyncManager
    let networkMonitor: NetworkMonitor
    
    @Published var syncState: SyncState = .idle
    
    init() {
        // setup SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        self.container = try! ModelContainer(
            for: Note.self, SyncOperation.self,
            configurations: config
        )
        
        let context = container.mainContext
        
        // wire up all dependencies
        self.storage = SwiftDataNoteStorage(context: context)
        self.queue = SyncQueue(context: context)
        self.syncManager = SyncManager(
            storage: storage,
            apiClient: MockAPIClient(),
            queue: queue
        )
        self.networkMonitor = NetworkMonitor(syncManager: syncManager)
        
        // start monitoring network
        networkMonitor.startMonitoring()
        
        // observe sync status stream
        Task {
            for await state in await syncManager.statusStream {
                self.syncState = state
            }
        }
    }
}
