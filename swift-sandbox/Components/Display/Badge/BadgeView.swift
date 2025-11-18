//
//  BadgeView.swift
//  swift-sandbox
//
//  Badge component
//

import SwiftUI

/// A small visual indicator for status, count, or category
public struct BadgeView: View {
    @Environment(\.appStore) private var store
    
    let text: String?
    let variant: BadgeVariant
    let size: BadgeSize
    let isDot: Bool
    
    /// Create a badge with text
    public init(
        text: String,
        variant: BadgeVariant = .primary,
        size: BadgeSize = .medium
    ) {
        self.text = text
        self.variant = variant
        self.size = size
        self.isDot = false
    }
    
    /// Create a dot badge (no text)
    public init(
        variant: BadgeVariant = .primary,
        size: BadgeSize = .medium,
        isDot: Bool = true
    ) {
        self.text = nil
        self.variant = variant
        self.size = size
        self.isDot = isDot
    }
    
    public var body: some View {
        if isDot {
            dotBadge
        } else {
            textBadge
        }
    }
    
    // MARK: - Text Badge
    private var textBadge: some View {
        Text(text ?? "")
            .font(.system(size: size.fontSize, weight: size.fontWeight))
            .foregroundStyle(.white)
            .padding(.horizontal, size.paddingHorizontal)
            .padding(.vertical, size.paddingVertical)
            .frame(minHeight: size.minHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
    }
    
    // MARK: - Dot Badge
    private var dotBadge: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: size.dotSize, height: size.dotSize)
    }
    
    // MARK: - Background Color
    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return store.themeColors.blue
        case .secondary:
            return store.themeColors.gray
        case .success:
            return store.themeColors.green
        case .warning:
            return store.themeColors.orange
        case .error:
            return store.themeColors.red
        case .info:
            return store.themeColors.teal
        case .neutral:
            return store.themeColors.gray3
        }
    }
}

// MARK: - Previews
#Preview("Badge Variants") {
    let store = AppStore()
    
    VStack(spacing: 16) {
        // All variants
        VStack(alignment: .leading, spacing: 12) {
            Text("Variants")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "Primary", variant: .primary)
                BadgeView(text: "Secondary", variant: .secondary)
                BadgeView(text: "Success", variant: .success)
            }
            
            HStack(spacing: 12) {
                BadgeView(text: "Warning", variant: .warning)
                BadgeView(text: "Error", variant: .error)
                BadgeView(text: "Info", variant: .info)
            }
            
            HStack(spacing: 12) {
                BadgeView(text: "Neutral", variant: .neutral)
            }
        }
        
        Divider()
        
        // All sizes
        VStack(alignment: .leading, spacing: 12) {
            Text("Sizes")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "Small", variant: .primary, size: .small)
                BadgeView(text: "Medium", variant: .primary, size: .medium)
                BadgeView(text: "Large", variant: .primary, size: .large)
            }
        }
        
        Divider()
        
        // Dot variants
        VStack(alignment: .leading, spacing: 12) {
            Text("Dot Badges")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(variant: .primary, size: .small, isDot: true)
                BadgeView(variant: .success, size: .medium, isDot: true)
                BadgeView(variant: .error, size: .large, isDot: true)
            }
        }
        
        Divider()
        
        // Number badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Number Badges")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "1", variant: .error, size: .small)
                BadgeView(text: "5", variant: .error, size: .medium)
                BadgeView(text: "99+", variant: .error, size: .large)
            }
        }
    }
    .padding()
    .environment(\.appStore, store)
}

#Preview("Badge in Context") {
    let store = AppStore()
    
    VStack(spacing: 24) {
        // With text
        HStack {
            Text("Notifications")
                .font(.headline)
            BadgeView(text: "3", variant: .error, size: .small)
            Spacer()
        }
        
        // With icon (simulated)
        HStack {
            Image(systemName: "bell.fill")
                .font(.title2)
            BadgeView(variant: .error, size: .small, isDot: true)
                .offset(x: -8, y: -8)
        }
        
        // Status indicator
        HStack {
            BadgeView(variant: .success, size: .small, isDot: true)
            Text("Online")
                .font(.subheadline)
        }
        
        // Multiple badges
        HStack(spacing: 8) {
            BadgeView(text: "iOS", variant: .info, size: .small)
            BadgeView(text: "Swift", variant: .primary, size: .small)
            BadgeView(text: "New", variant: .success, size: .small)
        }
    }
    .padding()
    .environment(\.appStore, store)
}

// MARK: - Previews
#Preview("Badge Variants") {
    let store = AppStore()
    
    return VStack(spacing: 16) {
        // All variants
        VStack(alignment: .leading, spacing: 12) {
            Text("Variants")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "Primary", variant: .primary)
                BadgeView(text: "Secondary", variant: .secondary)
                BadgeView(text: "Success", variant: .success)
            }
            
            HStack(spacing: 12) {
                BadgeView(text: "Warning", variant: .warning)
                BadgeView(text: "Error", variant: .error)
                BadgeView(text: "Info", variant: .info)
            }
            
            HStack(spacing: 12) {
                BadgeView(text: "Neutral", variant: .neutral)
            }
        }
        
        Divider()
        
        // All sizes
        VStack(alignment: .leading, spacing: 12) {
            Text("Sizes")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "Small", variant: .primary, size: .small)
                BadgeView(text: "Medium", variant: .primary, size: .medium)
                BadgeView(text: "Large", variant: .primary, size: .large)
            }
        }
        
        Divider()
        
        // Dot variants
        VStack(alignment: .leading, spacing: 12) {
            Text("Dot Badges")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(variant: .primary, size: .small, isDot: true)
                BadgeView(variant: .success, size: .medium, isDot: true)
                BadgeView(variant: .error, size: .large, isDot: true)
            }
        }
        
        Divider()
        
        // Number badges
        VStack(alignment: .leading, spacing: 12) {
            Text("Number Badges")
                .font(.headline)
            
            HStack(spacing: 12) {
                BadgeView(text: "1", variant: .error, size: .small)
                BadgeView(text: "5", variant: .error, size: .medium)
                BadgeView(text: "99+", variant: .error, size: .large)
            }
        }
    }
    .padding()
    .environment(\.appStore, store)
}

#Preview("Badge in Context") {
    let store = AppStore()
    
    return VStack(spacing: 24) {
        // With text
        HStack {
            Text("Notifications")
                .font(.headline)
            BadgeView(text: "3", variant: .error, size: .small)
            Spacer()
        }
        
        // With icon (simulated)
        HStack {
            Image(systemName: "bell.fill")
                .font(.title2)
            BadgeView(variant: .error, size: .small, isDot: true)
                .offset(x: -8, y: -8)
        }
        
        // Status indicator
        HStack {
            BadgeView(variant: .success, size: .small, isDot: true)
            Text("Online")
                .font(.subheadline)
        }
        
        // Multiple badges
        HStack(spacing: 8) {
            BadgeView(text: "iOS", variant: .info, size: .small)
            BadgeView(text: "Swift", variant: .primary, size: .small)
            BadgeView(text: "New", variant: .success, size: .small)
        }
    }
    .padding()
    .environment(\.appStore, store)
}

#Preview("Dark Mode") {
    let store = AppStore()
    store.setColorScheme(.dark)
    
    return VStack(spacing: 16) {
        HStack(spacing: 12) {
            BadgeView(text: "Primary", variant: .primary)
            BadgeView(text: "Success", variant: .success)
            BadgeView(text: "Error", variant: .error)
        }
        
        HStack(spacing: 12) {
            BadgeView(variant: .primary, isDot: true)
            BadgeView(variant: .success, isDot: true)
            BadgeView(variant: .error, isDot: true)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}
