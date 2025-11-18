//
//  TextStyles.swift
//  swift-sandbox
//
//  Created by seung joon lee on 17.11.2025.
//

import SwiftUI

// MARK: - Text Style Enum
public enum TextStyle {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption1
    case caption2
    
    var size: CGFloat {
        switch self {
        case .largeTitle: return AppTypography.Size.largeTitle
        case .title1: return AppTypography.Size.title1
        case .title2: return AppTypography.Size.title2
        case .title3: return AppTypography.Size.title3
        case .headline: return AppTypography.Size.headline
        case .body: return AppTypography.Size.body
        case .callout: return AppTypography.Size.callout
        case .subheadline: return AppTypography.Size.subheadline
        case .footnote: return AppTypography.Size.footnote
        case .caption1: return AppTypography.Size.caption1
        case .caption2: return AppTypography.Size.caption2
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .largeTitle: return AppTypography.LineHeight.largeTitle
        case .title1: return AppTypography.LineHeight.title1
        case .title2: return AppTypography.LineHeight.title2
        case .title3: return AppTypography.LineHeight.title3
        case .headline: return AppTypography.LineHeight.headline
        case .body: return AppTypography.LineHeight.body
        case .callout: return AppTypography.LineHeight.callout
        case .subheadline: return AppTypography.LineHeight.subheadline
        case .footnote: return AppTypography.LineHeight.footnote
        case .caption1: return AppTypography.LineHeight.caption1
        case .caption2: return AppTypography.LineHeight.caption2
        }
    }
    
    var defaultWeight: Font.Weight {
        switch self {
        case .largeTitle, .title1, .title2, .title3, .headline:
            return AppTypography.Weight.bold
        case .body, .callout, .subheadline, .footnote, .caption1, .caption2:
            return AppTypography.Weight.regular
        }
    }
}

// MARK: - View Extension for Text Styling
extension View {
    /// Apply a text style with optional weight
    /// Note: Color should be applied separately using .foregroundStyle()
    ///
    /// Example:
    /// ```
    /// Text("Hello")
    ///     .textStyle(.body, weight: .semibold)
    ///     .foregroundStyle(store.themeColors.labelPrimary)
    /// ```
    public func textStyle(
        _ style: TextStyle,
        weight: Font.Weight? = nil
    ) -> some View {
        self
            .font(.system(
                size: style.size,
                weight: weight ?? style.defaultWeight
            ))
            .lineSpacing(style.lineHeight - style.size)
    }
}
