import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]
    @State private var newItemTitle = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("添加新待办事项", text: $newItemTitle)
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newItemTitle.isEmpty)
                    }
                }
                
                Section("未完成") {
                    ForEach(items.filter { !$0.isCompleted }) { item in
                        TodoItemRow(item: item)
                    }
                    .onDelete(perform: deleteItems)
                }
                
                Section("已完成") {
                    ForEach(items.filter { $0.isCompleted }) { item in
                        TodoItemRow(item: item)
                    }
                }
            }
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: BurstView()) {
                        Text("开始专注")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = TodoItem(title: newItemTitle)
            modelContext.insert(newItem)
            newItemTitle = ""
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items.filter { !$0.isCompleted }[index])
            }
        }
    }
}

struct TodoItemRow: View {
    @Bindable var item: TodoItem
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    item.complete()
                }
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
            }
            
            Text(item.title)
                .strikethrough(item.isCompleted)
                .foregroundColor(item.isCompleted ? .gray : .primary)
        }
    }
}

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
} 