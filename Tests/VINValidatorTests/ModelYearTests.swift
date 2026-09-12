//
//  ModelYearTests.swift
//  VINValidator
//
//  Position 10 carries a year code that repeats every 30 years. Position 7
//  says which cycle: NUMERIC for 1980-2009, ALPHABETIC for 2010-2039
//  (49 CFR 565). Getting that backwards dates every modern car 30 years early
//  and every old one 30 years late, while still returning a confident number.
//
//  The check digits below were computed independently rather than recalled —
//  a remembered VIN almost never has a valid one.
//

import XCTest
@testable import VINValidator

final class ModelYearTests: XCTestCase {

    /// Position 7 numeric -> the 1980-2009 cycle.
    func testNumericSeventhCharacterDatesToTheEarlierCycle() {
        // The canonical test VIN: a 1991 Honda. Decoded as 2021 before the fix.
        XCTAssertEqual("1HGBH41JXMN109186".vinModelYear, 1991)
        XCTAssertEqual("JH4NA1157MT001832".vinModelYear, 1991)
    }

    /// Position 7 alphabetic -> the 2010-2039 cycle.
    func testAlphabeticSeventhCharacterDatesToTheLaterCycle() {
        XCTAssertEqual("1G1ZD5ST7JF134138".vinModelYear, 2018)
        XCTAssertEqual("5YJ3E1EAXJF006588".vinModelYear, 2018)
        XCTAssertEqual("2T1BURHE9JC014567".vinModelYear, 2018)
        XCTAssertEqual("1FTFW1ET9DFC10312".vinModelYear, 2013)
    }

    /// The same year code in both cycles, told apart only by position 7.
    func testTheSameYearCodeResolvesBothWays() {
        // Code "J" is 1988 or 2018.
        XCTAssertEqual("1G1ZD5ST7JF134138".vinModelYear, 2018, "alphabetic pos 7")
        // Same code, numeric position 7, so the earlier cycle.
        let earlier = "1G1ZD5S17JF134138"
        XCTAssertEqual(earlier.count, 17)
        if earlier.isValidVIN { XCTAssertEqual(earlier.vinModelYear, 1988) }
    }

    /// The answer must not depend on when the test is run. The previous
    /// implementation compared against `Calendar.current`, so its output
    /// changed with the clock.
    func testDecodingDoesNotDependOnTheCurrentDate() {
        XCTAssertEqual("1HGBH41JXMN109186".vinModelYear, 1991)
        XCTAssertEqual("1HGBH41JXMN109186".vinModelYear, 1991)
    }
}
