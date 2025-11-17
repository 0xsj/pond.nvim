//
//  ContentView.swift
//  swift-sandbox
//
//  Created by seung joon lee on 12.11.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appTheme) var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    Text("🔤")
                        .font(.system(size: 48))
                    
                    Text("Typography System")
                        .textStyle(.title1)
                        .themedForeground(.primary)
                    
                    Text("All text styles with sizes and weights")
                        .textStyle(.body, color: .secondary)
                }
                .paddingTop(.xl)
                
                // Typography styles
                VStack(spacing: AppSpacing.lg) {
                    // Large Title
                    TypographyRow(
                        label: "Large Title",
                        example: "Large Title Text"
                    ) {
                        Text("Large Title Text")
                            .textStyle(.largeTitle)
                            .themedForeground(.primary)
                    }
                    
                    // Title 1
                    TypographyRow(
                        label: "Title 1",
                        example: "Title 1 Text"
                    ) {
                        Text("Title 1 Text")
                            .textStyle(.title1)
                            .themedForeground(.primary)
                    }
                    
                    // Title 2
                    TypographyRow(
                        label: "Title 2",
                        example: "Title 2 Text"
                    ) {
                        Text("Title 2 Text")
                            .textStyle(.title2)
                            .themedForeground(.primary)
                    }
                    
                    // Title 3
                    TypographyRow(
                        label: "Title 3",
                        example: "Title 3 Text"
                    ) {
                        Text("Title 3 Text")
                            .textStyle(.title3)
                            .themedForeground(.primary)
                    }
                    
                    // Headline
                    TypographyRow(
                        label: "Headline",
                        example: "Headline Text"
                    ) {
                        Text("Headline Text")
                            .textStyle(.headline)
                            .themedForeground(.primary)
                    }
                    
                    // Body
                    TypographyRow(
                        label: "Body",
                        example: "Body Text"
                    ) {
                        Text("Body Text")
                            .textStyle(.body)
                            .themedForeground(.primary)
                    }
                    
                    // Callout
                    TypographyRow(
                        label: "Callout",
                        example: "Callout Text"
                    ) {
                        Text("Callout Text")
                            .textStyle(.callout)
                            .themedForeground(.primary)
                    }
                    
                    // Subheadline
                    TypographyRow(
                        label: "Subheadline",
                        example: "Subheadline Text"
                    ) {
                        Text("Subheadline Text")
                            .textStyle(.subheadline)
                            .themedForeground(.primary)
                    }
                    
                    // Footnote
                    TypographyRow(
                        label: "Footnote",
                        example: "Footnote Text"
                    ) {
                        Text("Footnote Text")
                            .textStyle(.footnote)
                            .themedForeground(.primary)
                    }
                    
                    // Caption 1
                    TypographyRow(
                        label: "Caption 1",
                        example: "Caption 1 Text"
                    ) {
                        Text("Caption 1 Text")
                            .textStyle(.caption1)
                            .themedForeground(.primary)
                    }
                    
                    // Caption 2
                    TypographyRow(
                        label: "Caption 2",
                        example: "Caption 2 Text"
                    ) {
                        Text("Caption 2 Text")
                            .textStyle(.caption2)
                            .themedForeground(.primary)
                    }
                    
                    // Color variations
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Color Levels")
                            .textStyle(.headline)
                            .themedForeground(.primary)
                            .padding(.sm)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Primary Label")
                                .textStyle(.body, color: .primary)
                            
                            Text("Secondary Label")
                                .textStyle(.body, color: .secondary)
                            
                            Text("Tertiary Label")
                                .textStyle(.body, color: .tertiary)
                            
                            Text("Quaternary Label")
                                .textStyle(.body, color: .quaternary)
                        }
                        .padding(.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .surfaceStyle(background: .secondary, radius: .md, elevation: .sm)
                    }
                    
                    // Weight variations
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Font Weights")
                            .textStyle(.headline)
                            .themedForeground(.primary)
                            .padding(.sm)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Regular Weight")
                                .textStyle(.body, weight: AppTypography.Weight.regular)
                                .themedForeground(.primary)
                            
                            Text("Medium Weight")
                                .textStyle(.body, weight: AppTypography.Weight.medium)
                                .themedForeground(.primary)
                            
                            Text("Semibold Weight")
                                .textStyle(.body, weight: AppTypography.Weight.semibold)
                                .themedForeground(.primary)
                            
                            Text("Bold Weight")
                                .textStyle(.body, weight: AppTypography.Weight.bold)
                                .themedForeground(.primary)
                            
                            Text("Heavy Weight")
                                .textStyle(.body, weight: AppTypography.Weight.heavy)
                                .themedForeground(.primary)
                        }
                        .padding(.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .surfaceStyle(background: .secondary, radius: .md, elevation: .sm)
                    }
                }
                .paddingHorizontal(.lg)
            }
            .frame(maxWidth: .infinity)
        }
        .themedBackground(.primary)
    }
}

// Helper component for typography rows
struct TypographyRow<Content: View>: View {
    let label: String
    let example: String
    @ViewBuilder let content: () -> Content
    @Environment(\.appTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(label)
                    .textStyle(.caption1, weight: AppTypography.Weight.semibold)
                    .themedForeground(.tertiary)
                
                Spacer()
                
                Text("\(Int(getSize(for: example)))pt")
                    .textStyle(.caption2)
                    .themedForeground(.quaternary)
            }
            
            content()
        }
    }
    
    private func getSize(for text: String) -> CGFloat {
        // This is a simplified version - in reality you'd map the style
        return 17 // Default body size
    }
}

#Preview("Light Mode") {
    ContentView()
        .environment(\.colorScheme, .light)
}

#Preview("Dark Mode") {
    ContentView()
        .environment(\.colorScheme, .dark)
}
