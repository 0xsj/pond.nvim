//
//  LayoutExtensions.swift
//  swift-sandbox
//
//  Layout utilities using design tokens
//

import SwiftUI

// MARK: - Padding Extensions
extension View {
    /// Apply padding using design tokens
    public func padding(_ spacing: PaddingToken) -> some View {
        self.padding(spacing.value)
    }
    
    /// Apply horizontal padding using design tokens
    public func paddingHorizontal(_ spacing: PaddingToken) -> some View {
        self.padding(.horizontal, spacing.value)
    }
    
    /// Apply vertical padding using design tokens
    public func paddingVertical(_ spacing: PaddingToken) -> some View {
        self.padding(.vertical, spacing.value)
    }
    
    /// Apply leading padding using design tokens
    public func paddingLeading(_ spacing: PaddingToken) -> some View {
        self.padding(.leading, spacing.value)
    }
    
    /// Apply trailing padding using design tokens
    public func paddingTrailing(_ spacing: PaddingToken) -> some View {
        self.padding(.trailing, spacing.value)
    }
    
    /// Apply top padding using design tokens
    public func paddingTop(_ spacing: PaddingToken) -> some View {
        self.padding(.top, spacing.value)
    }
    
    /// Apply bottom padding using design tokens
    public func paddingBottom(_ spacing: PaddingToken) -> some View {
        self.padding(.bottom, spacing.value)
    }
}

// MARK: - Corner Radius Extensions
extension View {
    /// Apply corner radius using design tokens
    public func radius(_ radius: RadiusToken) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius.value))
    }
}

// MARK: - Shadow/Elevation Extensions
extension View {
    /// Apply elevation (shadow) using design tokens
    public func elevation(_ elevation: ElevationToken) -> some View {
        self.shadow(
            color: Color.black.opacity(0.1),
            radius: elevation.value,
            x: 0,
            y: elevation.value / 2
        )
    }
}

// MARK: - Spacing Tokens
public enum PaddingToken {
    case xxs, xs, sm, md, lg, xl, xxl, xxxl, xxxxl
    
    var value: CGFloat {
        switch self {
        case .xxs: return AppSpacing.xxs
        case .xs: return AppSpacing.xs
        case .sm: return AppSpacing.sm
        case .md: return AppSpacing.md
        case .lg: return AppSpacing.lg
        case .xl: return AppSpacing.xl
        case .xxl: return AppSpacing.xxl
        case .xxxl: return AppSpacing.xxxl
        case .xxxxl: return AppSpacing.xxxxl
        }
    }
}

// MARK: - Radius Tokens
public enum RadiusToken {
    case none, xs, sm, md, lg, xl, xxl, full
    
    var value: CGFloat {
        switch self {
        case .none: return AppRadius.none
        case .xs: return AppRadius.xs
        case .sm: return AppRadius.sm
        case .md: return AppRadius.md
        case .lg: return AppRadius.lg
        case .xl: return AppRadius.xl
        case .xxl: return AppRadius.xxl
        case .full: return AppRadius.full
        }
    }
}

// MARK: - Elevation Tokens
public enum ElevationToken {
    case none, sm, md, lg, xl
    
    var value: CGFloat {
        switch self {
        case .none: return AppElevation.none
        case .sm: return AppElevation.sm
        case .md: return AppElevation.md
        case .lg: return AppElevation.lg
        case .xl: return AppElevation.xl
        }
    }
}
