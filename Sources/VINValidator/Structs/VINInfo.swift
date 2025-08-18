//
//  VINInfo.swift
//  VINValidator
//
//  Created by David Sherlock on 18/08/2025.
//

import Foundation

/// Comprehensive information extracted from a VIN.
public struct VINInfo: Sendable {
    public let vin: String
    public let isValid: Bool
    public let wmi: String  // World Manufacturer Identifier
    public let vds: String  // Vehicle Descriptor Section
    public let vis: String  // Vehicle Identifier Section
    public let manufacturer: String?
    public let modelYear: Int?
    public let assemblyPlant: String?
    public let serialNumber: String
    public let region: String?
    public let country: String?
    public let vehicleType: VehicleType?
}
