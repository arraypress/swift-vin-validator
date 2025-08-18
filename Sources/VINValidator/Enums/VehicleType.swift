//
//  VehicleType.swift
//  VINValidator
//
//  Created by David Sherlock on 18/08/2025.
//

import Foundation

/// Types of vehicles that can be identified from VIN.
public enum VehicleType: String, CaseIterable, Sendable {
    case passenger = "Passenger Car"
    case truck = "Truck"
    case multipurpose = "Multipurpose Vehicle"
    case bus = "Bus"
    case motorcycle = "Motorcycle"
    case trailer = "Trailer"
    case incomplete = "Incomplete Vehicle"
}
