//
//  Avatar+Types.swift
//  swift-sandbox
//
//  Avatar component types and enums
//

import SwiftUI

/// Avatar size
public enum AvatarSize {
    case xs
    case sm
    case md
    case lg
    case xl
    
    var dimension: CGFloat {
        switch self {
        case .xs: return 24
        case .sm: return 32
        case .md: return 40
        case .lg: return 48
        case .xl: return 64
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .xs: return AppTypography.Size.caption2
        case .sm: return AppTypography.Size.caption1
        case .md: return AppTypography.Size.subheadline
        case .lg: return AppTypography.Size.body
        case .xl: return AppTypography.Size.headline
        }
    }
    
    var statusSize: CGFloat {
        switch self {
        case .xs: return 6
        case .sm: return 8
        case .md: return 10
        case .lg: return 12
        case .xl: return 14
        }
    }
}

/// Avatar status indicator
public enum AvatarStatus {
    case online
    case offline
    case busy
    case away
    
    var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .gray
        case .busy: return .red
        case .away: return .orange
        }
    }
}
