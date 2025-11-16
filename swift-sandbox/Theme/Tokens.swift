import SwiftUI

struct ColorValue {
    let light: Color
    let dark: Color
    
    var adaptive: Color {
        Color(light: light, dark: dark)
    }
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppColors {
    struct Label {
        static let primary = ColorValue(
            light: Color(hex: "#000000"),
            dark: Color(hex: "#FFFFFF")
        )
        static let secondary = ColorValue(
            light: Color(hex: "#3C3C43"),
            dark: Color(hex: "#EBEBF5")
        )
        static let tertiary = ColorValue(
            light: Color(hex: "#3C3C4399"),
            dark: Color(hex: "#EBEBF599")
        )
        static let quaternary = ColorValue(
            light: Color(hex: "#3C3C4366"),
            dark: Color(hex: "#EBEBF566")
        )
    }
    
    struct Fill {
        static let primary = ColorValue(
            light: Color(hex: "#78788033"),
            dark: Color(hex: "#7878805C")
        )
        static let secondary = ColorValue(
            light: Color(hex: "#78788028"),
            dark: Color(hex: "#78788051")
        )
        static let tertiary = ColorValue(
            light: Color(hex: "#7676801F"),
            dark: Color(hex: "#7676803D")
        )
        static let quaternary = ColorValue(
            light: Color(hex: "#74748014"),
            dark: Color(hex: "#7474802E")
        )
    }
    
    struct Background {
        static let primary = ColorValue(
            light: Color(hex: "#FFFFFF"),
            dark: Color(hex: "#000000")
        )
        static let secondary = ColorValue(
            light: Color(hex: "#F2F2F7"),
            dark: Color(hex: "#1C1C1E")
        )
        static let tertiary = ColorValue(
            light: Color(hex: "#FFFFFF"),
            dark: Color(hex: "#2C2C2E")
        )
    }
    
    struct Separator {
        static let opaque = ColorValue(
            light: Color(hex: "#C6C6C8"),
            dark: Color(hex: "#38383A")
        )
        static let nonOpaque = ColorValue(
            light: Color(hex: "#3C3C4349"),
            dark: Color(hex: "#54545899")
        )
    }
    
    static let blue = ColorValue(
        light: Color(hex: "#007AFF"),
        dark: Color(hex: "#0A84FF")
    )
    static let green = ColorValue(
        light: Color(hex: "#34C759"),
        dark: Color(hex: "#30D158")
    )
    static let indigo = ColorValue(
        light: Color(hex: "#5856D6"),
        dark: Color(hex: "#5E5CE6")
    )
    static let orange = ColorValue(
        light: Color(hex: "#FF9500"),
        dark: Color(hex: "#FF9F0A")
    )
    static let pink = ColorValue(
        light: Color(hex: "#FF2D55"),
        dark: Color(hex: "#FF375F")
    )
    static let purple = ColorValue(
        light: Color(hex: "#AF52DE"),
        dark: Color(hex: "#BF5AF2")
    )
    static let red = ColorValue(
        light: Color(hex: "#FF3B30"),
        dark: Color(hex: "#FF453A")
    )
    static let teal = ColorValue(
        light: Color(hex: "#5AC8FA"),
        dark: Color(hex: "#64D2FF")
    )
    static let yellow = ColorValue(
        light: Color(hex: "#FFCC00"),
        dark: Color(hex: "#FFD60A")
    )
    static let gray = ColorValue(
        light: Color(hex: "#8E8E93"),
        dark: Color(hex: "#98989D")
    )
    static let gray2 = ColorValue(
        light: Color(hex: "#AEAEB2"),
        dark: Color(hex: "#636366")
    )
    static let gray3 = ColorValue(
        light: Color(hex: "#C7C7CC"),
        dark: Color(hex: "#48484A")
    )
    static let gray4 = ColorValue(
        light: Color(hex: "#D1D1D6"),
        dark: Color(hex: "#3A3A3C")
    )
    static let gray5 = ColorValue(
        light: Color(hex: "#E5E5EA"),
        dark: Color(hex: "#2C2C2E")
    )
    static let gray6 = ColorValue(
        light: Color(hex: "#F2F2F7"),
        dark: Color(hex: "#1C1C1E")
    )
}

struct AppTypography {
    struct Size {
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
    }
    
    struct Weight {
        static let regular = Font.Weight(rawValue: 4)
        static let medium = Font.Weight(rawValue: 5)
        static let semibold = Font.Weight(rawValue: 6)
        static let bold = Font.Weight(rawValue: 7)
        static let heavy = Font.Weight(rawValue: 8)
    }
    
    struct LineHeight {
        static let largeTitle: CGFloat = 41
        static let title1: CGFloat = 34
        static let title2: CGFloat = 28
        static let title3: CGFloat = 25
        static let headline: CGFloat = 22
        static let body: CGFloat = 22
        static let callout: CGFloat = 21
        static let subheadline: CGFloat = 20
        static let footnote: CGFloat = 18
        static let caption1: CGFloat = 16
        static let caption2: CGFloat = 13
    }
}

struct AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let xxxxl: CGFloat = 40
}

struct AppRadius {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 10
    static let xl: CGFloat = 12
    static let xxl: CGFloat = 16
    static let full: CGFloat = 9999
}

struct AppElevation {
    static let none: CGFloat = 0
    static let sm: CGFloat = 1
    static let md: CGFloat = 2
    static let lg: CGFloat = 4
    static let xl: CGFloat = 8
}