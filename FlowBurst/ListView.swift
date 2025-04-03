import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [TodoList]
    @State private var showingAddList = false
    @State private var showingDeleteAlert = false
    @State private var listToDelete: TodoList?
    
    var recentlyDeletedList: TodoList? {
        lists.first { $0.isRecentlyDeleted }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(lists.filter { !$0.isRecentlyDeleted }) { list in
                        NavigationLink(destination: TodoListView(list: list)) {
                            HStack {
                                Text(list.title)
                                Spacer()
                                Text("\(list.items.count)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteLists)
                }
                
                if let recentlyDeleted = recentlyDeletedList {
                    Section {
                        NavigationLink(destination: TodoListView(list: recentlyDeleted)) {
                            HStack {
                                Text("最近删除")
                                Spacer()
                                Text("\(recentlyDeleted.items.count)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: { showingAddList = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("添加列表")
                        }
                    }
                }
            }
            .navigationTitle("我的列表")
            .sheet(isPresented: $showingAddList) {
                AddListView()
            }
            .alert("确认删除", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) {
                    listToDelete = nil
                }
                Button("删除", role: .destructive) {
                    if let list = listToDelete {
                        deleteList(list)
                    }
                }
            } message: {
                if let list = listToDelete {
                    Text("确定要删除\(list.title)吗？")
                }
            }
        }
        .onAppear {
            createDefaultLists()
        }
    }
    
    private func createDefaultLists() {
        if lists.isEmpty {
            let recentlyDeleted = TodoList(title: "最近删除", isRecentlyDeleted: true)
            modelContext.insert(recentlyDeleted)
        }
    }
    
    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            listToDelete = lists.filter { !$0.isRecentlyDeleted }[index]
            showingDeleteAlert = true
        }
    }
    
    private func deleteList(_ list: TodoList) {
        // 将列表中的项目移动到最近删除列表
        if let recentlyDeleted = lists.first(where: { $0.isRecentlyDeleted }) {
            for item in list.items {
                item.delete()
                item.list = recentlyDeleted
            }
        }
        modelContext.delete(list)
        listToDelete = nil
    }
}

struct AddListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var showingDiscardAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("列表名称", text: $title)
            }
            .navigationTitle("新建列表")
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
                        addList()
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
    
    private func addList() {
        let list = TodoList(title: title)
        modelContext.insert(list)
        dismiss()
    }
}

#Preview {
    ListView()
        .modelContainer(for: TodoList.self, inMemory: true)
} 
