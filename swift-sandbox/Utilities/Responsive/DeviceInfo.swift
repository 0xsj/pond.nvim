//
//  DeviceInfo.swift
//  swift-sandbox
//
//  Created by seung joon lee on 18.11.2025.
//

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Device information and screen dimensions
public struct DeviceInfo {
    /// Current screen width in points
    public let width: CGFloat
    
    /// Current screen height in points
    public let height: CGFloat
    
    /// Screen scale factor (1x, 2x, 3x)
    public let scale: CGFloat
    
    /// Dynamic type scale factor
    public let fontScale: CGFloat
    
    /// Current breakpoint based on width
    public let breakpoint: Breakpoint
    
    /// Is the device a phone (iPhone, iPod touch)
    public var isPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }
    
    /// Is the device a tablet (iPad)
    public var isTablet: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    /// Is the device a Mac
    public var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Is the device in landscape orientation
    public var isLandscape: Bool {
        return width > height
    }
    
    /// Is the device in portrait orientation
    public var isPortrait: Bool {
        return height > width
    }
    
    /// Initialize with current screen dimensions
    public init() {
        #if os(iOS)
        let screen = UIScreen.main.bounds
        self.width = screen.width
        self.height = screen.height
        self.scale = UIScreen.main.scale
        
        // Get dynamic type scale - simplified approach
        self.fontScale = 1.0 // We'll improve this later if needed
        #elseif os(macOS)
        let screen = NSScreen.main?.frame ?? .zero
        self.width = screen.width
        self.height = screen.height
        self.scale = NSScreen.main?.backingScaleFactor ?? 1.0
        self.fontScale = 1.0
        #else
        self.width = 0
        self.height = 0
        self.scale = 1.0
        self.fontScale = 1.0
        #endif
        
        self.breakpoint = Breakpoint.from(width: width)
    }
    
    /// Initialize with specific dimensions (for testing/preview)
    public init(width: CGFloat, height: CGFloat, scale: CGFloat = 2.0, fontScale: CGFloat = 1.0) {
        self.width = width
        self.height = height
        self.scale = scale
        self.fontScale = fontScale
        self.breakpoint = Breakpoint.from(width: width)
    }
}

// MARK: - Environment Key
private struct DeviceInfoKey: EnvironmentKey {
    static let defaultValue = DeviceInfo()
}

extension EnvironmentValues {
    /// Access device information from environment
    public var deviceInfo: DeviceInfo {
        get { self[DeviceInfoKey.self] }
        set { self[DeviceInfoKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    /// Inject device info into environment (automatically updates on dimension changes)
    public func withDeviceInfo() -> some View {
        self.modifier(DeviceInfoModifier())
    }
}

// MARK: - Device Info Modifier
private struct DeviceInfoModifier: ViewModifier {
    @State private var deviceInfo = DeviceInfo()
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .environment(\.deviceInfo, deviceInfo)
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                // Update device info on orientation change
                deviceInfo = DeviceInfo()
            }
        #else
        content
            .environment(\.deviceInfo, deviceInfo)
        #endif
    }
}
