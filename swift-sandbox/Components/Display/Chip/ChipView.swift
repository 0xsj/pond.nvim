//
//  ChipView.swift
//  swift-sandbox
//
//  Chip component
//

import SwiftUI

/// An interactive tag or category indicator
public struct ChipView: View {
    @Environment(\.appStore) private var store
    
    let text: String
    let variant: ChipVariant
    let size: ChipSize
    let leadingIcon: String?
    let isSelected: Bool
    let onTap: (() -> Void)?
    let onClose: (() -> Void)?
    
    /// Create a chip
    public init(
        text: String,
        variant: ChipVariant = .filled,
        size: ChipSize = .medium,
        leadingIcon: String? = nil,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.text = text
        self.variant = variant
        self.size = size
        self.leadingIcon = leadingIcon
        self.isSelected = isSelected
        self.onTap = onTap
        self.onClose = onClose
    }
    
    public var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 4) {
                // Leading icon
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: size.iconSize))
                        .foregroundStyle(textColor)
                }
                
                // Text
                Text(text)
                    .font(.system(size: size.fontSize, weight: .medium))
                    .foregroundStyle(textColor)
                
                // Close button
                if let onClose = onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: size.iconSize - 2, weight: .semibold))
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, size.horizontalPadding)
            .frame(height: size.height)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .strokeBorder(borderColor, lineWidth: variant == .outlined ? 1 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .filled:
            return isSelected ? store.themeColors.blue : store.themeColors.fillSecondary
        case .outlined:
            return isSelected ? store.themeColors.blue.opacity(0.1) : .clear
        }
    }
    
    private var textColor: Color {
        switch variant {
        case .filled:
            return isSelected ? .white : store.themeColors.labelPrimary
        case .outlined:
            return isSelected ? store.themeColors.blue : store.themeColors.labelPrimary
        }
    }
    
    private var borderColor: Color {
        switch variant {
        case .filled:
            return .clear
        case .outlined:
            return isSelected ? store.themeColors.blue : store.themeColors.separatorOpaque
        }
    }
}

// MARK: - Previews
#Preview("Chip Variants & Sizes") {
    let store = AppStore()
    
    return ScrollView {
        VStack(spacing: 24) {
            // Variants
            VStack(alignment: .leading, spacing: 16) {
                Text("Variants")
                    .font(.title2.bold())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Filled")
                        .font(.caption)
                        .foregroundStyle(store.themeColors.labelSecondary)
                    
                    HStack(spacing: 8) {
                        ChipView(text: "Default", variant: .filled)
                        ChipView(text: "Selected", variant: .filled, isSelected: true)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Outlined")
                        .font(.caption)
                        .foregroundStyle(store.themeColors.labelSecondary)
                    
                    HStack(spacing: 8) {
                        ChipView(text: "Default", variant: .outlined)
                        ChipView(text: "Selected", variant: .outlined, isSelected: true)
                    }
                }
            }
            
            // Sizes
            VStack(alignment: .leading, spacing: 16) {
                Text("Sizes")
                    .font(.title2.bold())
                
                HStack(spacing: 8) {
                    ChipView(text: "Small", size: .small)
                    ChipView(text: "Medium", size: .medium)
                    ChipView(text: "Large", size: .large)
                }
            }
            
            // With Icons
            VStack(alignment: .leading, spacing: 16) {
                Text("With Icons")
                    .font(.title2.bold())
                
                HStack(spacing: 8) {
                    ChipView(text: "Home", leadingIcon: "house.fill")
                    ChipView(text: "Favorite", leadingIcon: "heart.fill", isSelected: true)
                    ChipView(text: "Settings", leadingIcon: "gear")
                }
            }
            
            // Closeable
            VStack(alignment: .leading, spacing: 16) {
                Text("Closeable")
                    .font(.title2.bold())
                
                HStack(spacing: 8) {
                    ChipView(text: "Tag 1", onClose: { print("Close 1") })
                    ChipView(text: "Tag 2", onClose: { print("Close 2") })
                    ChipView(text: "Tag 3", onClose: { print("Close 3") })
                }
            }
            
            // Interactive
            VStack(alignment: .leading, spacing: 16) {
                Text("Interactive (Tappable)")
                    .font(.title2.bold())
                
                HStack(spacing: 8) {
                    ChipView(text: "Click me", onTap: { print("Tapped") })
                    ChipView(text: "And me", variant: .outlined, onTap: { print("Tapped") })
                }
            }
            
            // All features combined
            VStack(alignment: .leading, spacing: 16) {
                Text("Combined Features")
                    .font(.title2.bold())
                
                HStack(spacing: 8) {
                    ChipView(
                        text: "Filter",
                        leadingIcon: "line.3.horizontal.decrease.circle",
                        isSelected: true,
                        onTap: { print("Tapped") },
                        onClose: { print("Closed") }
                    )
                }
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

#Preview("Chip in Context") {
    let store = AppStore()
    
    return ScrollView {
        VStack(spacing: 16) {
            // Filter chips
            CardView(variant: .elevated) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Filters")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ChipView(text: "iOS", leadingIcon: "apple.logo", onClose: {})
                        ChipView(text: "Swift", onClose: {})
                        ChipView(text: "Published", leadingIcon: "checkmark.circle.fill", onClose: {})
                        ChipView(text: "2024", onClose: {})
                    }
                }
            }
            
            // Category selection
            CardView(variant: .outlined) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Categories")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ChipView(text: "Technology", variant: .outlined, isSelected: true, onTap: {})
                        ChipView(text: "Design", variant: .outlined, onTap: {})
                        ChipView(text: "Business", variant: .outlined, onTap: {})
                        ChipView(text: "Marketing", variant: .outlined, isSelected: true, onTap: {})
                        ChipView(text: "Finance", variant: .outlined, onTap: {})
                    }
                }
            }
            
            // User tags with avatar
            CardView(variant: .filled) {
                HStack(spacing: 12) {
                    AvatarView(initials: "JD", size: .md)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("John Doe")
                            .font(.headline)
                        
                        HStack(spacing: 6) {
                            ChipView(text: "Developer", size: .small)
                            ChipView(text: "Team Lead", size: .small, isSelected: true)
                        }
                    }
                    
                    Spacer()
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
        HStack(spacing: 8) {
            ChipView(text: "Filled")
            ChipView(text: "Selected", isSelected: true)
        }
        
        HStack(spacing: 8) {
            ChipView(text: "Outlined", variant: .outlined)
            ChipView(text: "Selected", variant: .outlined, isSelected: true)
        }
        
        HStack(spacing: 8) {
            ChipView(text: "With Icon", leadingIcon: "star.fill")
            ChipView(text: "Closeable", onClose: {})
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

// MARK: - Flow Layout Helper
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
