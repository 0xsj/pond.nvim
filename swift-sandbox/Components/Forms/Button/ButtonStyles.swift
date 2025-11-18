//
//  ButtonStyles.swift
//  swift-sandbox
//
//  Button styles using Observable store
//

import SwiftUI

// MARK: - Button Variant
public enum ButtonVariant {
    case primary
    case secondary
    case text
    case destructive
}

// MARK: - Button Size
public enum ButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .medium: return 40
        case .large: return 48
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return AppTypography.Size.callout
        case .medium: return AppTypography.Size.body
        case .large: return AppTypography.Size.headline
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return AppSpacing.md
        case .medium: return AppSpacing.lg
        case .large: return AppSpacing.xl
        }
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.appStore) var store
    @Environment(\.isEnabled) var isEnabled
    let size: ButtonSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: AppTypography.Weight.semibold))
            .foregroundStyle(.white)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(isEnabled ? store.themeColors.blue : store.themeColors.gray4)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.appStore) var store
    @Environment(\.isEnabled) var isEnabled
    let size: ButtonSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: AppTypography.Weight.semibold))
            .foregroundStyle(isEnabled ? store.themeColors.blue : store.themeColors.gray)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .strokeBorder(isEnabled ? store.themeColors.blue : store.themeColors.gray3, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Text Button Style
struct TextButtonStyle: ButtonStyle {
    @Environment(\.appStore) var store
    @Environment(\.isEnabled) var isEnabled
    let size: ButtonSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: AppTypography.Weight.semibold))
            .foregroundStyle(isEnabled ? store.themeColors.blue : store.themeColors.gray)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style
struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.appStore) var store
    @Environment(\.isEnabled) var isEnabled
    let size: ButtonSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: AppTypography.Weight.semibold))
            .foregroundStyle(.white)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(isEnabled ? store.themeColors.red : store.themeColors.gray4)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extension for Convenience
extension View {
    public func buttonVariant(_ variant: ButtonVariant, size: ButtonSize = .medium) -> some View {
        switch variant {
        case .primary:
            return AnyView(self.buttonStyle(PrimaryButtonStyle(size: size)))
        case .secondary:
            return AnyView(self.buttonStyle(SecondaryButtonStyle(size: size)))
        case .text:
            return AnyView(self.buttonStyle(TextButtonStyle(size: size)))
        case .destructive:
            return AnyView(self.buttonStyle(DestructiveButtonStyle(size: size)))
        }
    }
}
