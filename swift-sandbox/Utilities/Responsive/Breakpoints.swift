//
//  Breakpoints.swift
//  swift-sandbox
//
//  Created by seung joon lee on 18.11.2025.
//


import Foundation

/// Breakpoint types for responsive design
public enum Breakpoint: String, CaseIterable {
    case xs    // Small phones: 0+
    case sm    // Standard phones: 375+
    case md    // Tablets (portrait): 768+
    case lg    // Tablets (landscape): 1024+
    case xl    // Large tablets: 1280+
    case xxl   // Desktops: 1536+
    
    /// Minimum width in points for this breakpoint
    public var minWidth: CGFloat {
        switch self {
        case .xs: return 0
        case .sm: return 375
        case .md: return 768
        case .lg: return 1024
        case .xl: return 1280
        case .xxl: return 1536
        }
    }
    
    /// Get breakpoint from width
    public static func from(width: CGFloat) -> Breakpoint {
        if width >= 1536 { return .xxl }
        if width >= 1280 { return .xl }
        if width >= 1024 { return .lg }
        if width >= 768 { return .md }
        if width >= 375 { return .sm }
        return .xs
    }
    
    /// Check if this breakpoint is at or above another
    public func isAtLeast(_ other: Breakpoint) -> Bool {
        return self.minWidth >= other.minWidth
    }
    
    /// Check if this breakpoint is below another
    public func isBelow(_ other: Breakpoint) -> Bool {
        return self.minWidth < other.minWidth
    }
}
