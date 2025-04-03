//
//  FlowBurstApp.swift
//  FlowBurst
//
//  Created by Pascal Dai on 2025/4/2.
//

import SwiftUI
import SwiftData

@main
struct FlowBurstApp: App {
    var body: some Scene {
        WindowGroup {
            ListView()
        }
        .modelContainer(for: [TodoItem.self, TodoList.self])
    }
}
