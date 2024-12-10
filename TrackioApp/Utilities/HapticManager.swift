import UIKit

class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func trigger(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
