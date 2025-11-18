//
//  ContentView.swift
//  swift-sandbox
//
//  Created by seung joon lee on 12.11.2025.
//

import SwiftUI

struct ContentView: View {
    var store: AppStore  // Direct reference to observable store
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("📱")
                            .font(.system(size: 64))
                        
                        Text("Component Library")
                            .font(.largeTitle.bold())
                        
                        Text("iOS Design System")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                        
                        // Theme toggle
                        Button(action: { store.toggleColorScheme() }) {
                            HStack(spacing: 8) {
                                Image(systemName: store.isDark ? "moon.fill" : "sun.max.fill")
                                Text(store.isDark ? "Dark Mode" : "Light Mode")
                            }
                            .font(.system(size: AppTypography.Size.callout, weight: .medium))
                            .foregroundStyle(store.themeColors.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md)
                                    .fill(store.themeColors.fillSecondary)
                            )
                        }
                        
                        // Device info
                        HStack(spacing: 4) {
                            BadgeView(text: store.deviceInfo.breakpoint.rawValue.uppercased(), variant: .info, size: .small)
                            Text("•")
                                .foregroundStyle(store.themeColors.labelTertiary)
                            Text("\(Int(store.deviceInfo.width))×\(Int(store.deviceInfo.height))")
                                .font(.caption)
                                .foregroundStyle(store.themeColors.labelTertiary)
                        }
                    }
                    .padding(.top, 32)
                    
                    // Component Categories
                    VStack(spacing: 16) {
                        // Display Components
                        NavigationLink(destination: DisplayShowcaseView()) {
                            showcaseCard(
                                icon: "🎨",
                                title: "Display Components",
                                description: "Badge, Card, Avatar, Chip",
                                count: 4
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Typography (coming soon)
                        showcaseCard(
                            icon: "🔤",
                            title: "Typography",
                            description: "Text styles and weights",
                            count: 11,
                            isDisabled: true
                        )
                        
                        // Forms (coming soon)
                        showcaseCard(
                            icon: "📝",
                            title: "Form Components",
                            description: "Button, Input, Checkbox, etc.",
                            count: 0,
                            isDisabled: true
                        )
                        
                        // Feedback (coming soon)
                        showcaseCard(
                            icon: "💬",
                            title: "Feedback Components",
                            description: "Alert, Progress, Skeleton",
                            count: 0,
                            isDisabled: true
                        )
                        
                        // Overlays (coming soon)
                        showcaseCard(
                            icon: "⚡",
                            title: "Overlay Components",
                            description: "Modal, Toast, Bottom Sheet",
                            count: 0,
                            isDisabled: true
                        )
                    }
                    
                    // Stats
                    HStack(spacing: 16) {
                        statCard(value: "4", label: "Components")
                        statCard(value: "3", label: "Platforms")
                        statCard(value: "∞", label: "Possibilities")
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            .background(store.themeColors.backgroundPrimary)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    // MARK: - Showcase Card
    @ViewBuilder
    private func showcaseCard(
        icon: String,
        title: String,
        description: String,
        count: Int,
        isDisabled: Bool = false
    ) -> some View {
        CardView(variant: .elevated) {
            HStack(spacing: 16) {
                // Icon
                Text(icon)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(store.themeColors.fillSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(isDisabled ? store.themeColors.labelTertiary : store.themeColors.labelPrimary)
                        
                        if count > 0 {
                            BadgeView(text: "\(count)", variant: .primary, size: .small)
                        }
                        
                        if isDisabled {
                            BadgeView(text: "Soon", variant: .neutral, size: .small)
                        }
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
                
                Spacer()
                
                // Arrow
                if !isDisabled {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(store.themeColors.labelTertiary)
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
    }
    
    // MARK: - Stat Card
    private func statCard(value: String, label: String) -> some View {
        CardView(variant: .filled, padding: .md) {
            VStack(spacing: 4) {
                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(store.themeColors.blue)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Light Mode") {
    let store = AppStore()
    store.setColorScheme(.light)
    
    return ContentView(store: store)
}

#Preview("Dark Mode") {
    let store = AppStore()
    store.setColorScheme(.dark)
    
    return ContentView(store: store)
}
