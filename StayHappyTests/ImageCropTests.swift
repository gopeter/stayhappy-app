//
//  ImageCropTests.swift
//  StayHappyTests
//
//  Pins the image variant definitions and the focal-point crop geometry.
//
//  These exist because the crop was visibly wrong in a way that no compiler
//  could catch: a 2:1 file was rendered into a ~3:1 frame and SwiftUI
//  center-cropped a third of the height away, undoing the saliency work.
//  The invariants below are what keep the variants and the layout in agreement.
//

import CoreGraphics
import Testing

@testable import StayHappy

@Suite("Image variants")
struct ImageVariantTests {

    @Test("Pixel sizes match the declared aspect ratios")
    func pixelSizesMatchAspectRatios() {
        for variant in ImageVariant.allCases {
            let size = variant.pixelSize
            let actual = size.width / size.height

            #expect(
                abs(actual - variant.aspectRatio) < 0.001,
                "\(variant.rawValue) declares \(variant.aspectRatio) but its pixel size is \(actual)"
            )
        }
    }

    @Test("Variants are wide enough that cropping never upscales")
    func variantsFitWithinTheSourceBudget() {
        // ImageProcessingService normalizes sources to 2048px on the longest
        // edge. A variant wider than that would have to be upscaled.
        for variant in ImageVariant.allCases {
            #expect(variant.pixelSize.width <= 2048)
            #expect(variant.pixelSize.height <= 2048)
        }
    }

    @Test("Filenames are distinct and carry their suffix")
    func fileNamesAreDistinct() {
        let names = ImageVariant.allCases.map { $0.fileName(for: "photo") }

        #expect(Set(names).count == ImageVariant.allCases.count)
        for (variant, name) in zip(ImageVariant.allCases, names) {
            #expect(name == "photo" + variant.rawValue)
        }
    }

    @Test("bestMatch picks the nearest aspect ratio, not just anything wide")
    func bestMatchPicksNearestRatio() {
        // The regression this guards: the old code used `aspectRatio > 1.5`,
        // so a 3:1 tile silently received the 2:1 widget file.
        #expect(ImageVariant.bestMatch(for: CGSize(width: 362, height: 120)) == .tile3x1)
        #expect(ImageVariant.bestMatch(for: CGSize(width: 300, height: 150)) == .widget2x1)
        #expect(ImageVariant.bestMatch(for: CGSize(width: 150, height: 150)) == .widget1x1)
        #expect(ImageVariant.bestMatch(for: CGSize(width: 170, height: 150)) == .widget1x1)
    }

    @Test("A degenerate size does not crash")
    func bestMatchHandlesZeroHeight() {
        #expect(ImageVariant.bestMatch(for: CGSize(width: 100, height: 0)) == .widget1x1)
    }
}

@Suite("Focal point cropping")
struct ImageCropTests {

    private let service = ImageProcessingService.shared
    private let portrait = CGSize(width: 1200, height: 1600)
    private let landscape = CGSize(width: 2000, height: 1000)

    @Test("A crop keeps its target aspect ratio and stays inside the image")
    func cropsStayInBoundsAndKeepRatio() {
        let sizes = [portrait, landscape, CGSize(width: 800, height: 800)]
        let ratios: [CGFloat] = [1, 2, 3]
        let positions: [CGFloat] = [0, 0.25, 0.5, 0.75, 1]

        for size in sizes {
            for ratio in ratios {
                for x in positions {
                    for y in positions {
                        let rect = service.cropRect(
                            in: size,
                            aspectRatio: ratio,
                            focalPoint: CGPoint(x: x, y: y)
                        )

                        #expect(rect.minX >= -0.5)
                        #expect(rect.minY >= -0.5)
                        #expect(rect.maxX <= size.width + 0.5)
                        #expect(rect.maxY <= size.height + 0.5)

                        let actual = rect.width / rect.height
                        #expect(
                            abs(actual - ratio) < 0.02,
                            "wanted \(ratio), got \(actual) for size \(size) focal (\(x), \(y))"
                        )
                    }
                }
            }
        }
    }

    @Test("An off-centre subject survives a 3:1 crop")
    func offCentreSubjectSurvives() {
        // Subject occupies rows 200...400 of a 1600px tall image.
        let subjectTop: CGFloat = 200
        let subjectBottom: CGFloat = 400
        let focalY = ((subjectTop + subjectBottom) / 2) / portrait.height

        let rect = service.cropRect(
            in: portrait,
            aspectRatio: 3,
            focalPoint: CGPoint(x: 0.5, y: focalY)
        )

        #expect(rect.minY <= subjectTop)
        #expect(rect.maxY >= subjectBottom)

        // And the naive alternative would indeed have lost it, which is what
        // makes the focal point worth computing at all.
        let naiveTop = (portrait.height - rect.height) / 2
        #expect(naiveTop > subjectBottom)
    }

    @Test("Focal points at the edges clamp instead of leaving the image")
    func edgeFocalPointsClamp() {
        let top = service.cropRect(in: portrait, aspectRatio: 3, focalPoint: CGPoint(x: 0.5, y: 0))
        #expect(top.minY == 0)

        let bottom = service.cropRect(in: portrait, aspectRatio: 3, focalPoint: CGPoint(x: 0.5, y: 1))
        #expect(abs(bottom.maxY - portrait.height) < 1)

        let left = service.cropRect(in: landscape, aspectRatio: 1, focalPoint: CGPoint(x: 0, y: 0.5))
        #expect(left.minX == 0)

        let right = service.cropRect(in: landscape, aspectRatio: 1, focalPoint: CGPoint(x: 1, y: 0.5))
        #expect(abs(right.maxX - landscape.width) < 1)
    }

    @Test("A centred focal point yields a centred crop")
    func centredFocalPointCentresTheCrop() {
        let rect = service.cropRect(in: portrait, aspectRatio: 3, focalPoint: CGPoint(x: 0.5, y: 0.5))

        #expect(abs(rect.midY - portrait.height / 2) < 1)
        #expect(abs(rect.midX - portrait.width / 2) < 1)
    }

    @Test("The crop uses the full short edge rather than shrinking")
    func cropUsesFullExtentAvailable() {
        // 3:1 out of a portrait source is limited by width.
        let fromPortrait = service.cropRect(in: portrait, aspectRatio: 3, focalPoint: CGPoint(x: 0.5, y: 0.5))
        #expect(fromPortrait.width == portrait.width)

        // 1:1 out of a landscape source is limited by height.
        let fromLandscape = service.cropRect(in: landscape, aspectRatio: 1, focalPoint: CGPoint(x: 0.5, y: 0.5))
        #expect(fromLandscape.height == landscape.height)
    }
}
