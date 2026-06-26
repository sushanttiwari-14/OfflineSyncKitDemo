//
//  Item.swift
//  OfflineSyncKitDemo
//
//  Created by sushant tiwari on 26/06/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
