//
//  Item.swift
//  FlowBurst
//
//  Created by Pascal Dai on 2025/4/2.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    
    init(title: String) {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
    
    func complete() {
        self.isCompleted = true
        self.completedAt = Date()
    }
}
