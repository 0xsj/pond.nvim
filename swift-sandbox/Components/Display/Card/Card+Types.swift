//
//  Card+Types.swift
//  swift-sandbox
//
//  Card component types and enums
//

import SwiftUI

/// Card variant defining the visual style
public enum CardVariant {
    case elevated   // With shadow
    case outlined   // With border
    case filled     // Filled background
}

/// Card padding preset
public enum CardPadding {
    case none
    case sm
    case md
    case lg
    case custom(CGFloat)
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .sm: return AppSpacing.sm
        case .md: return AppSpacing.md
        case .lg: return AppSpacing.lg
        case .custom(let value): return value
        }
    }
}
