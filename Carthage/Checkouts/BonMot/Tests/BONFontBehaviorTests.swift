//
//  UIFontTests.swift
//  BonMot
//
//  Created by Brian King on 7/20/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
import BonMot

#if os(iOS) || os(tvOS) || os(watchOS)
#if swift(>=3.0)
    let testTextStyle = UIFontTextStyle.title3
#else
    let testTextStyle = UIFontTextStyleTitle3
#endif
#endif

/// Test the platform behavior of [NS|UI]Font
class BONFontBehaviorTests: XCTestCase {

    /// This tests explores how font attributes persist after construction.
    ///
    /// - note: When a font is created, attributes that are not supported are
    /// removed. It appears that font attributes only act as hints as to what
    /// features should be enabled in a font, but only if the font supports it.
    /// The features that are enabled are still in the font attributes after
    /// construction.
    func testBONFontDescriptors() {
        var attributes = BONFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[BONFontDescriptorFeatureSettingsAttribute] = [
            [
                BONFontFeatureTypeIdentifierKey: 1,
                BONFontFeatureSelectorIdentifierKey: 1,
            ],
        ]
        #if os(OSX)
            let newAttributes = BONFont(descriptor: BONFontDescriptor(fontAttributes: attributes), size: 0)?.fontDescriptor.fontAttributes ?? [:]
        #else
            let newAttributes = BONFont(descriptor: BONFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        #endif
        XCTAssertEqual(newAttributes.count, 2)
        XCTAssertEqual(newAttributes["NSFontNameAttribute"] as? String, "Avenir-Roman")
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }
    #if os(iOS) || os(tvOS) || os(watchOS)

    /// Test what happens when a non-standard text style string is supplied.
    func testUIFontNewTextStyle() {
        var attributes = UIFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[UIFontDescriptorFeatureSettingsAttribute] = [
            [
                UIFontFeatureTypeIdentifierKey: 1,
                UIFontFeatureSelectorIdentifierKey: 1,
            ],
        ]
        attributes[UIFontDescriptorTextStyleAttribute] = "Test"
        let newAttributes = UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        XCTAssertEqual(newAttributes.count, 2)
        XCTAssertEqual(newAttributes["NSFontNameAttribute"] as? String, "Avenir-Roman")
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }

    /// Demonstrate what happens when a text style feature is added to a
    /// non-system font. (It overrides the font.)
    func testTextStyleWithOtherFont() {
        var attributes = UIFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[UIFontDescriptorTextStyleAttribute] = testTextStyle
        let newAttributes = UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        XCTAssertEqual(newAttributes.count, 2)
        XCTAssertEqual(newAttributes["NSCTFontUIUsageAttribute"] as? BonMotTextStyle, testTextStyle)
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }
    #endif

}
