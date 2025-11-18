//
//  AvatarView.swift
//  swift-sandbox
//
//  Avatar component
//

import SwiftUI

/// A circular avatar displaying an image or initials
public struct AvatarView: View {
    @Environment(\.appStore) private var store
    
    let imageName: String?
    let initials: String?
    let size: AvatarSize
    let status: AvatarStatus?
    
    /// Create an avatar with an image
    public init(
        image: String,
        size: AvatarSize = .md,
        status: AvatarStatus? = nil
    ) {
        self.imageName = image
        self.initials = nil
        self.size = size
        self.status = status
    }
    
    /// Create an avatar with initials
    public init(
        initials: String,
        size: AvatarSize = .md,
        status: AvatarStatus? = nil
    ) {
        self.imageName = nil
        self.initials = initials
        self.size = size
        self.status = status
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
            
            if let status = status {
                statusIndicator(status)
                    .offset(x: 2, y: 2)
            }
        }
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let imageName = imageName, !imageName.isEmpty {
            // Try to load as system image or asset
            Image(systemName: imageName)
                .resizable()
                .scaledToFill()
                .foregroundStyle(store.themeColors.labelPrimary)
                .background(store.themeColors.fillSecondary)
        } else if let initials = initials {
            Text(initials.prefix(2).uppercased())
                .font(.system(size: size.fontSize, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(initialsGradient)
        } else {
            // Fallback placeholder
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(size.dimension * 0.25)
                .foregroundStyle(store.themeColors.labelSecondary)
                .background(store.themeColors.fillSecondary)
        }
    }
    
    private var initialsGradient: LinearGradient {
        // Generate a color based on initials for consistency
        let colors = [
            store.themeColors.blue,
            store.themeColors.purple,
            store.themeColors.pink,
            store.themeColors.orange,
            store.themeColors.teal,
            store.themeColors.indigo
        ]
        
        let index = abs((initials ?? "").hashValue % colors.count)
        let color = colors[index]
        
        return LinearGradient(
            colors: [color, color.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func statusIndicator(_ status: AvatarStatus) -> some View {
        Circle()
            .fill(status.color)
            .frame(width: size.statusSize, height: size.statusSize)
            .overlay(
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
            )
    }
}

// MARK: - Previews
#Preview("Avatar Sizes") {
    let store = AppStore()
    
    return VStack(spacing: 24) {
        Text("Avatar Sizes")
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
        
        // Sizes with initials
        VStack(alignment: .leading, spacing: 16) {
            Text("With Initials")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    AvatarView(initials: "SJ", size: .xs)
                    Text("XS").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "SJ", size: .sm)
                    Text("SM").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "SJ", size: .md)
                    Text("MD").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "SJ", size: .lg)
                    Text("LG").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "SJ", size: .xl)
                    Text("XL").font(.caption2)
                }
            }
        }
        
        // Different initials (different colors)
        VStack(alignment: .leading, spacing: 16) {
            Text("Different Users")
                .font(.headline)
            
            HStack(spacing: 16) {
                AvatarView(initials: "AB", size: .lg)
                AvatarView(initials: "CD", size: .lg)
                AvatarView(initials: "EF", size: .lg)
                AvatarView(initials: "GH", size: .lg)
            }
        }
        
        // With status indicators
        VStack(alignment: .leading, spacing: 16) {
            Text("With Status")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    AvatarView(initials: "JD", size: .lg, status: .online)
                    Text("Online").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "KL", size: .lg, status: .busy)
                    Text("Busy").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "MN", size: .lg, status: .away)
                    Text("Away").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "OP", size: .lg, status: .offline)
                    Text("Offline").font(.caption2)
                }
            }
        }
        
        // Fallback (no image or initials)
        VStack(alignment: .leading, spacing: 16) {
            Text("Fallback")
                .font(.headline)
            
            HStack(spacing: 16) {
                AvatarView(image: "", size: .sm)
                AvatarView(image: "", size: .md)
                AvatarView(image: "", size: .lg)
            }
        }
        
        Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

#Preview("Avatar in Card") {
    let store = AppStore()
    
    return VStack(spacing: 16) {
        CardView(variant: .elevated) {
            HStack(spacing: 12) {
                AvatarView(initials: "SJ", size: .lg, status: .online)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Seung Joon Lee")
                        .font(.headline)
                    Text("Software Engineer")
                        .font(.subheadline)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
                
                Spacer()
                
                BadgeView(text: "Pro", variant: .info, size: .small)
            }
        }
        
        CardView(variant: .outlined) {
            VStack(spacing: 12) {
                HStack {
                    AvatarView(initials: "TM", size: .md)
                    Text("Team Member")
                        .font(.subheadline)
                    Spacer()
                    BadgeView(text: "Active", variant: .success, size: .small)
                }
                
                Text("Last seen 5 minutes ago")
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}

#Preview("Dark Mode") {
    let store = AppStore()
    store.setColorScheme(.dark)
    
    return VStack(spacing: 24) {
        HStack(spacing: 16) {
            AvatarView(initials: "AB", size: .lg)
            AvatarView(initials: "CD", size: .lg, status: .online)
            AvatarView(initials: "EF", size: .lg, status: .busy)
        }
        
        CardView(variant: .elevated) {
            HStack(spacing: 12) {
                AvatarView(initials: "DM", size: .lg, status: .online)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dark Mode User")
                        .font(.headline)
                    Text("Online now")
                        .font(.subheadline)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(store.themeColors.backgroundPrimary)
    .environment(\.appStore, store)
}
