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
    var deletedAt: Date?
    @Relationship(deleteRule: .cascade) var list: TodoList?
    
    init(title: String, list: TodoList? = nil) {
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.list = list
    }
    
    func complete() {
        self.isCompleted = true
    }
    
    func delete() {
        self.deletedAt = Date()
    }
    
    func restore() {
        self.deletedAt = nil
    }
}
