import SwiftUI
import SwiftData

struct BurstView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [TodoItem]
    @Environment(\.dismiss) private var dismiss
    @State private var timeRemaining = 3 // 15 * 60=15分钟,测试的时候可以将时间调小一点
    @State private var timer: Timer?
    @State private var selectedItems: [TodoItem] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("专注时间")
                .font(.title)
            
            Text(timeString(from: timeRemaining))
                .font(.system(size: 60, weight: .bold))
            
            if !selectedItems.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("当前任务：")
                        .font(.headline)
                    
                    ForEach(selectedItems) { item in
                        Text(item.title)
                            .font(.body)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
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
    }
}

#Preview {
    NavigationStack {
        BurstView()
    }
    .modelContainer(for: TodoItem.self, inMemory: true)
} 
