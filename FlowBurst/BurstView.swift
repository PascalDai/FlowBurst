import SwiftUI
import SwiftData

struct BurstView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining = 3 // 15 * 60=15分钟,测试的时候可以将时间调小一点
    @State private var timer: Timer?
    @State private var selectedItems: [TodoItem] = []
    @State private var currentItemIndex = 0
    @State private var completedItems: [TodoItem] = []
    
    var body: some View {
        ZStack {
            // 背景视图，处理返回手势
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if timer == nil && gesture.translation.width > 100 {
                                dismiss()
                            }
                        }
                )
            
            VStack(spacing: 20) {
                Text("专注时间")
                    .font(.title)
                
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 60, weight: .bold))
                
                if !selectedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("待办任务：")
                            .font(.headline)
                        
                        ForEach(Array(selectedItems.enumerated()), id: \.element.id) { index, item in
                            TaskItemView(
                                item: item,
                                timer: timer,
                                onComplete: {
                                    item.complete()
                                    completedItems.append(item)
                                    moveToNextItem()
                                },
                                onSwap: {
                                    swapItem(at: index)
                                }
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !completedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("已完成任务：")
                            .font(.headline)
                        
                        ForEach(completedItems) { item in
                            Text(item.title)
                                .font(.body)
                                .strikethrough()
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Button(action: {
                    if timer == nil {
                        startTimer()
                    } else {
                        stopTimer()
                    }
                }) {
                    Text(timer == nil ? "开始" : "暂停")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(timer == nil ? Color.blue : Color.red)
                        .cornerRadius(25)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectRandomItems()
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                dismiss()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func selectRandomItems() {
        let incompleteItems = items.filter { !$0.isCompleted }
        let count = min(3, incompleteItems.count)
        selectedItems = Array(incompleteItems.shuffled().prefix(count))
        currentItemIndex = 0
        completedItems = []
    }
    
    private func swapItem(at index: Int) {
        // 获取所有未完成的任务
        let allIncompleteItems = items.filter { !$0.isCompleted }
        
        // 获取当前未在显示列表中的任务
        let availableItems = allIncompleteItems.filter { item in
            !selectedItems.contains { $0.id == item.id }
        }
        
        // 如果有可用的任务，随机选择一个进行交换
        if let newItem = availableItems.randomElement() {
            selectedItems[index] = newItem
        }
    }
    
    private func moveToNextItem() {
        if currentItemIndex < selectedItems.count - 1 {
            currentItemIndex += 1
        } else {
            // 所有任务都处理完了，返回上一页
            dismiss()
        }
    }
}

struct TaskItemView: View {
    let item: TodoItem
    let timer: Timer?
    let onComplete: () -> Void
    let onSwap: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        Text(item.title)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.isDragging = true
                        // 只允许水平移动
                        self.offset = CGSize(width: gesture.translation.width, height: 0)
                    }
                    .onEnded { gesture in
                        self.isDragging = false
                        let threshold: CGFloat = 100
                        
                        withAnimation {
                            if gesture.translation.width > threshold {
                                // 右滑完成（仅在倒计时开始后）
                                if timer != nil {
                                    onComplete()
                                }
                            } else if gesture.translation.width < -threshold {
                                // 左滑切换任务（随时可用）
                                onSwap()
                            }
                            self.offset = .zero
                        }
                    }
            )
    }
}

#Preview {
    NavigationStack {
        BurstView()
    }
    .modelContainer(for: TodoItem.self, inMemory: true)
} 
