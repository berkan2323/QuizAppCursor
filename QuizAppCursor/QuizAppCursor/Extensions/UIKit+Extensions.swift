import SwiftUI
import UIKit

extension Color {
    static var systemBackground: Color {
        Color(uiColor: .systemBackground)
    }
    
    static var secondarySystemBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
}

extension UIColor {
    static var adaptiveBackground: UIColor {
        UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .systemGray6
            default:
                return .systemBackground
            }
        }
    }
} 