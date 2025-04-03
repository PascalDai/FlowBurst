import Foundation
import SwiftData

@Model
final class TodoList {
    var title: String
    var createdAt: Date
    var items: [TodoItem]
    var isRecentlyDeleted: Bool
    
    init(title: String, isRecentlyDeleted: Bool = false) {
        self.title = title
        self.createdAt = Date()
        self.items = []
        self.isRecentlyDeleted = isRecentlyDeleted
    }
} 