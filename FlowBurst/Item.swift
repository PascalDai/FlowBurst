//
//  Item.swift
//  FlowBurst
//
//  Created by Pascal Dai on 2025/4/2.
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
