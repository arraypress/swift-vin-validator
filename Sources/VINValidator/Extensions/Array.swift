//
//  Array.swift
//  VINValidator
//
//  Created by David Sherlock on 18/08/2025.
//

import Foundation

public extension Array where Element == String {
    
    /// Filter array to only valid VINs.
    var validVINs: [String] {
        return filter { $0.isValidVIN }
    }
    
    /// Group VINs by manufacturer.
    var groupedByManufacturer: [String: [String]] {
        var grouped: [String: [String]] = [:]
        for vin in self {
            if let info = vin.vinInfo,
               let manufacturer = info.manufacturer {
                grouped[manufacturer, default: []].append(vin)
            }
        }
        return grouped
    }
    
    /// Group VINs by model year.
    var groupedByYear: [Int: [String]] {
        var grouped: [Int: [String]] = [:]
        for vin in self {
            if let info = vin.vinInfo,
               let year = info.modelYear {
                grouped[year, default: []].append(vin)
            }
        }
        return grouped
    }
    
    /// Get formatted versions of all VINs.
    var formattedVINs: [String] {
        return compactMap { $0.formattedVIN }
    }
    
}
