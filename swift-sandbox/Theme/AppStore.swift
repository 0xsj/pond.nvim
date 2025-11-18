//
//  AppStore.swift
//  swift-sandbox
//
//  Main observable store for app state
//

import SwiftUI
import Observation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Main app store containing theme and device information
@Observable
public class AppStore {
    /// Current color scheme (light/dark mode)
    public var colorScheme: ColorScheme = .light
    
    /// Device information
    public var deviceInfo: DeviceInfo = DeviceInfo()
    
    /// Computed responsive helper
    public var responsive: Responsive {
        Responsive(breakpoint: deviceInfo.breakpoint)
    }
    
    /// Is dark mode enabled
    public var isDark: Bool {
        colorScheme == .dark
    }
    
    /// Computed theme colors based on current color scheme
    public var themeColors: ThemeColors {
        ThemeColors(isDark: isDark)
    }
    
    /// Initialize store
    public init() {
        self.updateDeviceInfo()
        self.setupOrientationObserver()
    }
    
    /// Toggle between light and dark mode
    public func toggleColorScheme() {
        colorScheme = colorScheme == .light ? .dark : .light
    }
    
    /// Set color scheme explicitly
    public func setColorScheme(_ scheme: ColorScheme) {
        colorScheme = scheme
    }
    
    /// Update device info (called on orientation/size changes)
    public func updateDeviceInfo() {
        deviceInfo = DeviceInfo()
    }
    
    /// Setup observer for device orientation changes
    private func setupOrientationObserver() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateDeviceInfo()
        }
        #endif
    }
    
    deinit {
        #if os(iOS)
        NotificationCenter.default.removeObserver(self)
        #endif
    }
}

// MARK: - Theme Colors
public struct ThemeColors {
    let isDark: Bool
    
    // Label colors
    public var labelPrimary: Color { isDark ? AppColors.Label.primary.dark : AppColors.Label.primary.light }
    public var labelSecondary: Color { isDark ? AppColors.Label.secondary.dark : AppColors.Label.secondary.light }
    public var labelTertiary: Color { isDark ? AppColors.Label.tertiary.dark : AppColors.Label.tertiary.light }
    public var labelQuaternary: Color { isDark ? AppColors.Label.quaternary.dark : AppColors.Label.quaternary.light }
    
    // Fill colors
    public var fillPrimary: Color { isDark ? AppColors.Fill.primary.dark : AppColors.Fill.primary.light }
    public var fillSecondary: Color { isDark ? AppColors.Fill.secondary.dark : AppColors.Fill.secondary.light }
    public var fillTertiary: Color { isDark ? AppColors.Fill.tertiary.dark : AppColors.Fill.tertiary.light }
    public var fillQuaternary: Color { isDark ? AppColors.Fill.quaternary.dark : AppColors.Fill.quaternary.light }
    
    // Background colors
    public var backgroundPrimary: Color { isDark ? AppColors.Background.primary.dark : AppColors.Background.primary.light }
    public var backgroundSecondary: Color { isDark ? AppColors.Background.secondary.dark : AppColors.Background.secondary.light }
    public var backgroundTertiary: Color { isDark ? AppColors.Background.tertiary.dark : AppColors.Background.tertiary.light }
    
    // Separator colors
    public var separatorOpaque: Color { isDark ? AppColors.Separator.opaque.dark : AppColors.Separator.opaque.light }
    public var separatorNonOpaque: Color { isDark ? AppColors.Separator.nonOpaque.dark : AppColors.Separator.nonOpaque.light }
    
    // Accent colors
    public var blue: Color { isDark ? AppColors.blue.dark : AppColors.blue.light }
    public var green: Color { isDark ? AppColors.green.dark : AppColors.green.light }
    public var indigo: Color { isDark ? AppColors.indigo.dark : AppColors.indigo.light }
    public var orange: Color { isDark ? AppColors.orange.dark : AppColors.orange.light }
    public var pink: Color { isDark ? AppColors.pink.dark : AppColors.pink.light }
    public var purple: Color { isDark ? AppColors.purple.dark : AppColors.purple.light }
    public var red: Color { isDark ? AppColors.red.dark : AppColors.red.light }
    public var teal: Color { isDark ? AppColors.teal.dark : AppColors.teal.light }
    public var yellow: Color { isDark ? AppColors.yellow.dark : AppColors.yellow.light }
    
    // Gray scale
    public var gray: Color { isDark ? AppColors.gray.dark : AppColors.gray.light }
    public var gray2: Color { isDark ? AppColors.gray2.dark : AppColors.gray2.light }
    public var gray3: Color { isDark ? AppColors.gray3.dark : AppColors.gray3.light }
    public var gray4: Color { isDark ? AppColors.gray4.dark : AppColors.gray4.light }
    public var gray5: Color { isDark ? AppColors.gray5.dark : AppColors.gray5.light }
    public var gray6: Color { isDark ? AppColors.gray6.dark : AppColors.gray6.light }
}

// MARK: - Environment Key for AppStore
private struct AppStoreKey: EnvironmentKey {
    static let defaultValue = AppStore()
}

extension EnvironmentValues {
    /// Access app store from environment
    public var appStore: AppStore {
        get { self[AppStoreKey.self] }
        set { self[AppStoreKey.self] = newValue }
    }
}
