//
//  CardView.swift
//  swift-sandbox
//
//  Card component
//

import SwiftUI

/// A container component with background, border, and elevation
public struct CardView<Content: View>: View {
    @Environment(\.appStore) private var store
    
    let variant: CardVariant
    let padding: CardPadding
    let radius: RadiusToken
    let content: Content
    let onTap: (() -> Void)?
    
    /// Create a card with content
    public init(
        variant: CardVariant = .elevated,
        padding: CardPadding = .md,
        radius: RadiusToken = .md,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.padding = padding
        self.radius = radius
        self.onTap = onTap
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        switch variant {
        case .elevated:
            content
                .padding(padding.value)
                .background(backgroundColor)
                .border(Color.red, width: 2)
                .clipShape(RoundedRectangle(cornerRadius: radius.value))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: AppElevation.md,
                    x: 0,
                    y: AppElevation.md / 2
                )
        case .outlined:
            content
                .padding(padding.value)
                .border(Color.red, width: 2)
                .clipShape(RoundedRectangle(cornerRadius: radius.value))
                .overlay(
                    RoundedRectangle(cornerRadius: radius.value)
                        .strokeBorder(store.themeColors.separatorOpaque, lineWidth: 1)
                )
        case .filled:
            content
                .padding(padding.value)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: radius.value))
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .elevated:
            return store.themeColors.backgroundSecondary
        case .outlined:
            return store.themeColors.backgroundPrimary
        case .filled:
            return store.themeColors.backgroundSecondary
        }
    }
}

// MARK: - Previews
#Preview("Card Variants") {
    let store = AppStore()
    
    return ScrollView {
        VStack(spacing: 16) {
            Text("Card Variants")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Elevated card
            VStack(alignment: .leading, spacing: 8) {
                Text("Elevated")
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelSecondary)
                
                CardView(variant: .elevated) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elevated Card")
                            .font(.headline)
                        Text("This card has a shadow for depth")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Outlined card
            VStack(alignment: .leading, spacing: 8) {
                Text("Outlined")
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelSecondary)
                
                CardView(variant: .outlined) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outlined Card")
                            .font(.headline)
                        Text("This card has a border")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Filled card
            VStack(alignment: .leading, spacing: 8) {
                Text("Filled")
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelSecondary)
                
                CardView(variant: .filled) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Filled Card")
                            .font(.headline)
                        Text("This card has a filled background")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Different padding
            Text("Padding Sizes")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            CardView(variant: .elevated, padding: .sm) {
                Text("Small Padding")
                    .font(.subheadline)
            }
            
            CardView(variant: .elevated, padding: .md) {
                Text("Medium Padding (default)")
                    .font(.subheadline)
            }
            
            CardView(variant: .elevated, padding: .lg) {
                Text("Large Padding")
                    .font(.subheadline)
            }
            
            // Tappable card
            Text("Interactive")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            CardView(variant: .elevated, onTap: {
                print("Card tapped!")
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tappable Card")
                            .font(.headline)
                        Text("Tap me!")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(store.themeColors.labelTertiary)
                }
            }
        }
        .padding()
    }
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

#Preview("Card with Badge") {
    let store = AppStore()
    
    return VStack {
        CardView(variant: .elevated) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Notification")
                        .font(.headline)
                    Spacer()
                    BadgeView(text: "3", variant: .error, size: .small)
                }
                
                Text("You have unread messages")
                    .font(.subheadline)
                    .foregroundStyle(store.themeColors.labelSecondary)
                
                HStack(spacing: 8) {
                    BadgeView(text: "New", variant: .success, size: .small)
                    BadgeView(text: "Important", variant: .warning, size: .small)
                }
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

#Preview("Dark Mode") {
    let store = AppStore()
    store.setColorScheme(.dark)
    
    return VStack(spacing: 16) {
        CardView(variant: .elevated) {
            Text("Elevated in Dark Mode")
                .font(.headline)
        }
        
        CardView(variant: .outlined) {
            Text("Outlined in Dark Mode")
                .font(.headline)
        }
        
        CardView(variant: .filled) {
            Text("Filled in Dark Mode")
                .font(.headline)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}
