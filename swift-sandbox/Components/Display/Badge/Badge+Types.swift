//
//  Badge+Types.swift
//  swift-sandbox
//
//  Badge component types and enums
//

import SwiftUI

/// Badge variant defining the visual style
public enum BadgeVariant {
    case primary
    case secondary
    case success
    case warning
    case error
    case info
    case neutral
}

/// Badge size
public enum BadgeSize {
    case small
    case medium
    case large
    
    /// Font size for this badge size
    var fontSize: CGFloat {
        switch self {
        case .small: return AppTypography.Size.caption2
        case .medium: return AppTypography.Size.caption1
        case .large: return AppTypography.Size.footnote
        }
    }
    
    /// Font weight
    var fontWeight: Font.Weight {
        return AppTypography.Weight.semibold
    }
    
    /// Horizontal padding
    var paddingHorizontal: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 8
        case .large: return 10
        }
    }
    
    /// Vertical padding
    var paddingVertical: CGFloat {
        switch self {
        case .small: return 2
        case .medium: return 4
        case .large: return 6
        }
    }
    
    /// Minimum height for the badge
    var minHeight: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }
    
    /// Corner radius
    var cornerRadius: CGFloat {
        switch self {
        case .small: return AppRadius.xs
        case .medium: return AppRadius.sm
        case .large: return AppRadius.md
        }
    }
    
    /// Dot diameter (for dot variant)
    var dotSize: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 10
        case .large: return 12
        }
    }
}
