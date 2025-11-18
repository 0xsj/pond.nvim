//
//  ResponsiveHelpers.swift
//  swift-sandbox
//
//  Created by seung joon lee on 18.11.2025.
//

import SwiftUI

/// A value that can vary by breakpoint
public struct ResponsiveValue<T> {
    private let values: [Breakpoint: T]
    private let fallback: T?
    
    /// Create a responsive value with breakpoint-specific values
    public init(_ values: [Breakpoint: T]) {
        self.values = values
        self.fallback = nil
    }
    
    /// Create a responsive value with a default fallback
    public init(default: T, _ values: [Breakpoint: T] = [:]) {
        self.fallback = `default`
        self.values = values
    }
    
    /// Resolve to a single value based on current breakpoint
    /// Falls back to next smallest breakpoint if current not defined
    public func resolve(for breakpoint: Breakpoint) -> T? {
        // Ordered breakpoints from largest to smallest
        let ordered: [Breakpoint] = [.xxl, .xl, .lg, .md, .sm, .xs]
        
        // Find current breakpoint index
        guard let currentIndex = ordered.firstIndex(of: breakpoint) else {
            return fallback
        }
        
        // Look for matching breakpoint or next smallest with a value
        for i in currentIndex..<ordered.count {
            if let value = values[ordered[i]] {
                return value
            }
        }
        
        // Return fallback if no breakpoint matched
        return fallback
    }
}

// MARK: - Responsive Helper Functions
public struct Responsive {
    private let breakpoint: Breakpoint
    
    public init(breakpoint: Breakpoint) {
        self.breakpoint = breakpoint
    }
    
    /// Resolve a responsive value to a single value
    public func resolve<T>(_ value: ResponsiveValue<T>) -> T? {
        return value.resolve(for: breakpoint)
    }
    
    /// Check if current breakpoint is at or above a specific breakpoint
    public func isAtLeast(_ target: Breakpoint) -> Bool {
        return breakpoint.isAtLeast(target)
    }
    
    /// Check if current breakpoint is below a specific breakpoint
    public func isBelow(_ target: Breakpoint) -> Bool {
        return breakpoint.isBelow(target)
    }
}

// MARK: - Environment Access
extension EnvironmentValues {
    /// Access responsive helper from environment
    public var responsive: Responsive {
        Responsive(breakpoint: deviceInfo.breakpoint)
    }
}

// MARK: - Convenience Functions
extension View {
    /// Show view only on specific breakpoints
    public func showOn(_ breakpoints: [Breakpoint]) -> some View {
        self.modifier(ShowOnBreakpointModifier(breakpoints: breakpoints))
    }
    
    /// Hide view on specific breakpoints
    public func hideOn(_ breakpoints: [Breakpoint]) -> some View {
        self.modifier(HideOnBreakpointModifier(breakpoints: breakpoints))
    }
}

// MARK: - Breakpoint Visibility Modifiers
private struct ShowOnBreakpointModifier: ViewModifier {
    @Environment(\.deviceInfo) var deviceInfo
    let breakpoints: [Breakpoint]
    
    func body(content: Content) -> some View {
        if breakpoints.contains(deviceInfo.breakpoint) {
            content
        }
    }
}

private struct HideOnBreakpointModifier: ViewModifier {
    @Environment(\.deviceInfo) var deviceInfo
    let breakpoints: [Breakpoint]
    
    func body(content: Content) -> some View {
        if !breakpoints.contains(deviceInfo.breakpoint) {
            content
        }
    }
}
