//
//  String.swift
//  VINValidator
//
//  Created by David Sherlock on 18/08/2025.
//

import Foundation

public extension String {
    
    /// Check if this string is a valid VIN.
    ///
    /// Validates according to ISO 3779 standard:
    /// - Must be exactly 17 characters
    /// - No I, O, or Q allowed
    /// - Check digit (position 9) must be valid
    var isValidVIN: Bool {
        return VINValidator.validate(self)
    }
    
    /// Get comprehensive VIN information.
    ///
    /// Extracts manufacturer, year, plant, and other data from the VIN.
    var vinInfo: VINInfo? {
        return VINValidator.decode(self)
    }
    
    /// Get the manufacturer from the VIN.
    ///
    /// Uses the World Manufacturer Identifier (first 3 characters).
    var vinManufacturer: String? {
        return vinInfo?.manufacturer
    }
    
    /// Get the model year from the VIN.
    ///
    /// Decodes from position 10 of the VIN.
    var vinModelYear: Int? {
        return vinInfo?.modelYear
    }
    
    /// Get the formatted VIN with proper spacing.
    ///
    /// Format: XXX XXXXXX XXXXXXXX
    var formattedVIN: String? {
        guard isValidVIN else { return nil }
        return VINValidator.format(self)
    }
    
    /// Get the check digit for this VIN.
    ///
    /// Returns the calculated check digit (position 9).
    var vinCheckDigit: Character? {
        return VINValidator.calculateCheckDigit(self)
    }
    
}
