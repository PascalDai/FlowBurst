import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]
    @State private var showingAddItem = false
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: TodoItem?
    
    let list: TodoList
    
    var filteredItems: [TodoItem] {
        items.filter { $0.list?.id == list.id }
    }
    
    var body: some View {
        List {
            Section {
                ForEach(filteredItems.filter { !$0.isCompleted }) { item in
                    TodoItemRow(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                itemToDelete = item
                                showingDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            
            Section("已完成") {
                ForEach(filteredItems.filter { $0.isCompleted }) { item in
                    TodoItemRow(item: item)
                }
            }
        }
        .navigationTitle(list.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: BurstView()) {
                    Text("开始专注")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: { showingAddItem = true }) {
                    Text("新提醒事项")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(list: list)
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {
                itemToDelete = nil
            }
            Button("删除", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
        } message: {
            if let item = itemToDelete {
                Text("确定要删除\(item.title)吗？")
            }
        }
    }
    
    private func deleteItem(_ item: TodoItem) {
        if list.isRecentlyDeleted {
            modelContext.delete(item)
        } else {
            item.delete()
            if let recentlyDeleted = items.first(where: { $0.list?.isRecentlyDeleted == true })?.list {
                item.list = recentlyDeleted
            }
        }
        itemToDelete = nil
    }
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var showingDiscardAlert = false
    
    let list: TodoList
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("待办事项", text: $title)
            }
            .navigationTitle("新建待办事项")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        if !title.isEmpty {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("放弃更改？", isPresented: $showingDiscardAlert) {
                Button("取消", role: .cancel) { }
                Button("放弃", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("确定要放弃当前的更改吗？")
            }
        }
    }
    
    private func addItem() {
        let item = TodoItem(title: title, list: list)
        modelContext.insert(item)
        dismiss()
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
    
    let list = TodoList(title: "测试列表")
    container.mainContext.insert(list)
    
    let items = [
        "完成项目文档",
        "代码审查",
        "团队会议",
        "回复邮件",
        "准备周报",
        "修复 Bug",
        "更新依赖",
        "优化性能"
    ]
    
    for title in items {
        let item = TodoItem(title: title, list: list)
        container.mainContext.insert(item)
    }
    
    let completedItems = try! container.mainContext.fetch(FetchDescriptor<TodoItem>())
    completedItems[0].complete()
    completedItems[1].complete()
    completedItems[2].complete()
    
    return NavigationStack {
        TodoListView(list: list)
    }
    .modelContainer(container)
} 
