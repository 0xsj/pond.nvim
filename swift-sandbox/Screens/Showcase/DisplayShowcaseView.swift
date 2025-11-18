//
//  DisplayShowcaseView.swift
//  swift-sandbox
//
//  Showcase for all Display components
//

import SwiftUI

struct DisplayShowcaseView: View {
    @Environment(\.appStore) private var store
    @State private var selectedChips: Set<String> = ["Technology"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                headerSection
                
                // Badge Section
                badgeSection
                
                Divider()
                
                // Avatar Section
                avatarSection
                
                Divider()
                
                // Card Section
                cardSection
                
                Divider()
                
                // Chip Section
                chipSection
                
                Divider()
                
                // Combined Example
                combinedSection
            }
            .padding()
        }
        .background(store.themeColors.backgroundPrimary)
        .navigationTitle("Display Components")
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🎨")
                .font(.system(size: 48))
            
            Text("Display Components")
                .font(.largeTitle.bold())
            
            Text("Visual indicators and containers")
                .font(.subheadline)
                .foregroundStyle(store.themeColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Badge Section
    private var badgeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges")
                .font(.title2.bold())
            
            Text("Small status indicators")
                .font(.caption)
                .foregroundStyle(store.themeColors.labelSecondary)
            
            // All variants
            FlowLayout(spacing: 8) {
                BadgeView(text: "Primary", variant: .primary)
                BadgeView(text: "Secondary", variant: .secondary)
                BadgeView(text: "Success", variant: .success)
                BadgeView(text: "Warning", variant: .warning)
                BadgeView(text: "Error", variant: .error)
                BadgeView(text: "Info", variant: .info)
                BadgeView(text: "Neutral", variant: .neutral)
            }
            
            // Sizes
            HStack(spacing: 12) {
                BadgeView(text: "S", variant: .primary, size: .small)
                BadgeView(text: "M", variant: .primary, size: .medium)
                BadgeView(text: "L", variant: .primary, size: .large)
            }
            
            // Dots
            HStack(spacing: 12) {
                BadgeView(variant: .success, size: .small, isDot: true)
                BadgeView(variant: .warning, size: .medium, isDot: true)
                BadgeView(variant: .error, size: .large, isDot: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Avatar Section
    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Avatars")
                .font(.title2.bold())
            
            Text("User profile images and initials")
                .font(.caption)
                .foregroundStyle(store.themeColors.labelSecondary)
            
            // Sizes
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    AvatarView(initials: "XS", size: .xs)
                    Text("XS").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "SM", size: .sm)
                    Text("SM").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "MD", size: .md)
                    Text("MD").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "LG", size: .lg)
                    Text("LG").font(.caption2)
                }
                VStack(spacing: 4) {
                    AvatarView(initials: "XL", size: .xl)
                    Text("XL").font(.caption2)
                }
            }
            
            // With status
            HStack(spacing: 16) {
                AvatarView(initials: "ON", size: .lg, status: .online)
                AvatarView(initials: "BS", size: .lg, status: .busy)
                AvatarView(initials: "AW", size: .lg, status: .away)
                AvatarView(initials: "OF", size: .lg, status: .offline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Card Section
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cards")
                .font(.title2.bold())
            
            Text("Container components")
                .font(.caption)
                .foregroundStyle(store.themeColors.labelSecondary)
            
            // Elevated
            CardView(variant: .elevated, padding: .md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Elevated Card")
                        .font(.headline)
                    Text("With shadow for depth")
                        .font(.caption)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
            }
            
            // Outlined
            CardView(variant: .outlined, padding: .md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outlined Card")
                        .font(.headline)
                    Text("With border")
                        .font(.caption)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
            }
            
            // Filled
            CardView(variant: .filled, padding: .md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Filled Card")
                        .font(.headline)
                    Text("With background")
                        .font(.caption)
                        .foregroundStyle(store.themeColors.labelSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Chip Section
    private var chipSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chips")
                .font(.title2.bold())
            
            Text("Interactive tags and filters")
                .font(.caption)
                .foregroundStyle(store.themeColors.labelSecondary)
            
            // Basic chips
            FlowLayout(spacing: 8) {
                ChipView(text: "Swift")
                ChipView(text: "iOS")
                ChipView(text: "Mobile", isSelected: true)
            }
            
            // With icons
            FlowLayout(spacing: 8) {
                ChipView(text: "Home", leadingIcon: "house.fill")
                ChipView(text: "Favorites", leadingIcon: "heart.fill", isSelected: true)
                ChipView(text: "Settings", leadingIcon: "gear")
            }
            
            // Closeable
            FlowLayout(spacing: 8) {
                ChipView(text: "Filter 1", onClose: {})
                ChipView(text: "Filter 2", onClose: {})
                ChipView(text: "Filter 3", onClose: {})
            }
            
            // Outlined variant
            FlowLayout(spacing: 8) {
                ForEach(["Technology", "Design", "Business", "Marketing"], id: \.self) { category in
                    ChipView(
                        text: category,
                        variant: .outlined,
                        isSelected: selectedChips.contains(category),
                        onTap: {
                            if selectedChips.contains(category) {
                                selectedChips.remove(category)
                            } else {
                                selectedChips.insert(category)
                            }
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Combined Section
    private var combinedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Real-World Examples")
                .font(.title2.bold())
            
            Text("Components working together")
                .font(.caption)
                .foregroundStyle(store.themeColors.labelSecondary)
            
            // User profile card
            CardView(variant: .elevated) {
                HStack(spacing: 12) {
                    AvatarView(initials: "SJ", size: .lg, status: .online)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Seung Joon Lee")
                                .font(.headline)
                            BadgeView(text: "Pro", variant: .info, size: .small)
                        }
                        
                        Text("Software Engineer")
                            .font(.subheadline)
                            .foregroundStyle(store.themeColors.labelSecondary)
                        
                        HStack(spacing: 6) {
                            ChipView(text: "iOS", size: .small)
                            ChipView(text: "Swift", size: .small)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            // Notification card
            CardView(variant: .outlined) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(store.themeColors.blue)
                        Text("Notifications")
                            .font(.headline)
                        Spacer()
                        BadgeView(text: "3", variant: .error, size: .small)
                    }
                    
                    Text("You have unread notifications")
                        .font(.subheadline)
                        .foregroundStyle(store.themeColors.labelSecondary)
                    
                    FlowLayout(spacing: 8) {
                        ChipView(text: "Mentions", size: .small, leadingIcon: "at")
                        ChipView(text: "Messages", size: .small, leadingIcon: "message.fill")
                        ChipView(text: "Updates", size: .small, leadingIcon: "arrow.triangle.2.circlepath")
                    }
                }
            }
            
            // Team members
            CardView(variant: .filled) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Team Members")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        teamMemberRow(initials: "JD", name: "John Doe", role: "Designer", status: .online)
                        teamMemberRow(initials: "SA", name: "Sarah Anderson", role: "Engineer", status: .busy)
                        teamMemberRow(initials: "MK", name: "Mike Kim", role: "Product Manager", status: .away)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func teamMemberRow(initials: String, name: String, role: String, status: AvatarStatus) -> some View {
        HStack(spacing: 12) {
            AvatarView(initials: initials, size: .md, status: status)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.medium))
                Text(role)
                    .font(.caption)
                    .foregroundStyle(store.themeColors.labelSecondary)
            }
            
            Spacer()
            
            BadgeView(variant: statusBadgeVariant(status), size: .small, isDot: true)
        }
    }
    
    private func statusBadgeVariant(_ status: AvatarStatus) -> BadgeVariant {
        switch status {
        case .online: return .success
        case .busy: return .error
        case .away: return .warning
        case .offline: return .neutral
        }
    }
}

#Preview("Display Showcase") {
    let store = AppStore()
    
    return NavigationStack {
        DisplayShowcaseView()
            .environment(\.appStore, store)
    }
}

#Preview("Dark Mode") {
    let store = AppStore()
    store.setColorScheme(.dark)
    
    return NavigationStack {
        DisplayShowcaseView()
            .environment(\.appStore, store)
    }
}
