//
//import Foundation
//
//struct PendingChange: Identifiable {
//    let id = UUID()
//    let kind: ChangeKind   // e.g., .addTodo, .updateEmotion
//    let payload: Data      // or strongly-typed
//    var attempts: Int = 0
//}
//
//final class SyncManager: ObservableObject {
//    static let shared = SyncManager()
//    @Published private(set) var queue: [PendingChange] = []
//
//    func enqueue(_ change: PendingChange) {
//        queue.append(change)
//        process()
//    }
//
//    private func process() {
//        Task { [weak self] in
//            guard let self else { return }
//            for i in queue.indices {
//                var change = queue[i]
//                do {
//                    try await APIClient.shared.send(change)
//                    // on success: drop it
//                    await MainActor.run { self.queue.removeAll { $0.id == change.id } }
//                } catch {
//                    change.attempts += 1
//                    if change.attempts >= 3 {
//                        // mark unsynced / surface error to user
//                    } else {
//                        // exponential backoff
//                        try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(change.attempts)) * 1_000_000_000))
//                        queue[i] = change
//                        process()
//                    }
//                    break
//                }
//            }
//        }
//    }
//}
