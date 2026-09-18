//
//  ImageVariant.swift
//  StayHappy
//
//  Single source of truth for the pre-rendered image variants that are stored
//  alongside each original photo.
//
//  Before this type existed, the filename suffixes and the aspect ratios were
//  spelled out separately in ImageProcessingService, ImageSaver,
//  WidgetImageMigrationService and HighlightsTile — and they had drifted apart,
//  which is why crops looked off: a 2:1 file was being displayed in a 3:1 frame
//  and SwiftUI center-cropped the difference away.
//

import CoreGraphics

enum ImageVariant: String, CaseIterable, Sendable {
    /// Wide variant, for medium widgets.
    case widget2x1 = "_widget_2x1"

    /// Square variant, for small widgets.
    case widget1x1 = "_widget_1x1"

    /// Extra-wide variant, for the in-app highlight tiles and the form preview.
    case tile3x1 = "_tile_3x1"

    var aspectRatio: CGFloat {
        switch self {
        case .widget2x1: 2
        case .widget1x1: 1
        case .tile3x1: 3
        }
    }

    /// The rendered size, in pixels.
    ///
    /// Deliberately a fixed pixel size rather than something derived from
    /// `UIScreen.main.bounds.width`: a file generated on one device has to be
    /// valid on every other one, and regeneration has to be deterministic.
    /// 1200px covers the widest phone at 3x with room to spare.
    var pixelSize: CGSize {
        switch self {
        case .widget2x1: CGSize(width: 1200, height: 600)
        case .widget1x1: CGSize(width: 600, height: 600)
        case .tile3x1: CGSize(width: 1200, height: 400)
        }
    }

    /// The filename of this variant for a given base photo name, without extension.
    func fileName(for baseName: String) -> String {
        baseName + rawValue
    }

    /// The variant whose aspect ratio is closest to `size`.
    ///
    /// Replaces the old `aspectRatio > 1.5` threshold, which lumped everything
    /// wider than 1.5 into the 2:1 variant — including the 3:1 highlight tile.
    static func bestMatch(for size: CGSize) -> ImageVariant {
        guard size.height > 0 else { return .widget1x1 }
        let target = size.width / size.height

        return allCases.min {
            abs($0.aspectRatio - target) < abs($1.aspectRatio - target)
        } ?? .widget1x1
    }
}
