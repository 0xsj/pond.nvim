//
//  Chip+Types.swift
//  swift-sandbox
//
//  Chip component types and enums
//

import SwiftUI

/// Chip variant defining the visual style
public enum ChipVariant {
    case filled
    case outlined
}

/// Chip size
public enum ChipSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 24
        case .medium: return 28
        case .large: return 32
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return AppTypography.Size.caption2
        case .medium: return AppTypography.Size.caption1
        case .large: return AppTypography.Size.footnote
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 10
        case .large: return 12
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }
}
