//
//  AppTheme.swift
//  swift-sandbox
//
//  Created by seung joon lee on 17.11.2025.
//

import SwiftUI

// MARK: - Theme Environment Key
private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Theme Model
struct AppTheme {
    @Environment(\.colorScheme) private var colorScheme
    
    var isDark: Bool {
        colorScheme == .dark
    }
    
    // Color accessors
    func color(_ colorValue: ColorValue) -> Color {
        colorValue.adaptive
    }
    
    // Convenience accessors for common colors
    var labelPrimary: Color { AppColors.Label.primary.adaptive }
    var labelSecondary: Color { AppColors.Label.secondary.adaptive }
    var labelTertiary: Color { AppColors.Label.tertiary.adaptive }
    var labelQuaternary: Color { AppColors.Label.quaternary.adaptive }
    
    var fillPrimary: Color { AppColors.Fill.primary.adaptive }
    var fillSecondary: Color { AppColors.Fill.secondary.adaptive }
    var fillTertiary: Color { AppColors.Fill.tertiary.adaptive }
    var fillQuaternary: Color { AppColors.Fill.quaternary.adaptive }
    
    var backgroundPrimary: Color { AppColors.Background.primary.adaptive }
    var backgroundSecondary: Color { AppColors.Background.secondary.adaptive }
    var backgroundTertiary: Color { AppColors.Background.tertiary.adaptive }
    
    var separatorOpaque: Color { AppColors.Separator.opaque.adaptive }
    var separatorNonOpaque: Color { AppColors.Separator.nonOpaque.adaptive }
    
    var blue: Color { AppColors.blue.adaptive }
    var green: Color { AppColors.green.adaptive }
    var indigo: Color { AppColors.indigo.adaptive }
    var orange: Color { AppColors.orange.adaptive }
    var pink: Color { AppColors.pink.adaptive }
    var purple: Color { AppColors.purple.adaptive }
    var red: Color { AppColors.red.adaptive }
    var teal: Color { AppColors.teal.adaptive }
    var yellow: Color { AppColors.yellow.adaptive }
    var gray: Color { AppColors.gray.adaptive }
    var gray2: Color { AppColors.gray2.adaptive }
    var gray3: Color { AppColors.gray3.adaptive }
    var gray4: Color { AppColors.gray4.adaptive }
    var gray5: Color { AppColors.gray5.adaptive }
    var gray6: Color { AppColors.gray6.adaptive }
}

// MARK: - View Extension for Theme Access
extension View {
    func themedBackground(_ level: BackgroundLevel = .primary) -> some View {
        self.modifier(ThemedBackgroundModifier(level: level))
    }
    
    func themedForeground(_ level: LabelLevel = .primary) -> some View {
        self.modifier(ThemedForegroundModifier(level: level))
    }
}

// MARK: - Background Levels
enum BackgroundLevel {
    case primary, secondary, tertiary
}

// MARK: - Label Levels
enum LabelLevel {
    case primary, secondary, tertiary, quaternary
}

// MARK: - View Modifiers
private struct ThemedBackgroundModifier: ViewModifier {
    @Environment(\.appTheme) var theme
    let level: BackgroundLevel
    
    func body(content: Content) -> some View {
        content.background(backgroundColor)
    }
    
    private var backgroundColor: Color {
        switch level {
        case .primary: return theme.backgroundPrimary
        case .secondary: return theme.backgroundSecondary
        case .tertiary: return theme.backgroundTertiary
        }
    }
}

private struct ThemedForegroundModifier: ViewModifier {
    @Environment(\.appTheme) var theme
    let level: LabelLevel
    
    func body(content: Content) -> some View {
        content.foregroundStyle(foregroundColor)
    }
    
    private var foregroundColor: Color {
        switch level {
        case .primary: return theme.labelPrimary
        case .secondary: return theme.labelSecondary
        case .tertiary: return theme.labelTertiary
        case .quaternary: return theme.labelQuaternary
        }
    }
}
