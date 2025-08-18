# Swift VIN Validator

A comprehensive Vehicle Identification Number (VIN) validation library for Swift, compliant with ISO 3779 standard. Validates check digits, detects manufacturers, and extracts vehicle information from VINs.

## Features

- ✅ **ISO 3779 compliant** - Full VIN standard implementation
- ✅ **Check digit validation** - Modulo 11 weighted algorithm
- ✅ **100+ manufacturers** - Ford, GM, Honda, Toyota, BMW, Mercedes, Tesla, and more
- ✅ **Data extraction** - Manufacturer, year, plant, country, region
- ✅ **WMI/VDS/VIS parsing** - Complete VIN structure breakdown
- ✅ **Year decoding** - Model year with 30-year cycle handling
- ✅ **Assembly plant detection** - Major plants for key manufacturers
- ✅ **Country/region identification** - Full geographic decoding
- ✅ **Zero dependencies** - Pure Swift implementation
- ✅ **Swift-native APIs** - Natural extensions on String and Array
- ✅ **High performance** - Optimized validation algorithms
- ✅ **Thread-safe** - No shared mutable state
- ✅ **Comprehensive tests** - 27+ test cases with edge cases

## Installation

### Swift Package Manager

Add VINValidator to your project using Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/arraypress/swift-vin-validator`
3. Select your desired version

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-vin-validator", from: "1.0.0")
]
```

## Quick Start

```swift
import VINValidator

// Basic validation
"1HGBH41JXMN109186".isValidVIN          // true (Honda)
"INVALIDVIN123456".isValidVIN           // false

// Manufacturer detection
"1HGBH41JXMN109186".vinManufacturer     // "Honda"
"5YJ3E1EA5KF328931".vinManufacturer     // "Tesla"
"WBA3A5C59FP215853".vinManufacturer     // "BMW"

// Year extraction
"1HGBH41JXMN109186".vinModelYear        // 2021
"1G1JC5444R7252367".vinModelYear        // 1994

// Full VIN information
let info = "1HGBH41JXMN109186".vinInfo
// info.manufacturer: "Honda"
// info.modelYear: 2021
// info.country: "United States"
// info.region: "North America"
// info.wmi: "1HG"
// info.vds: "BH41JX"
// info.vis: "MN109186"
// info.serialNumber: "109186"

// Formatting
"1HGBH41JXMN109186".formattedVIN        // "1HG BH41JX MN109186"

// Check digit calculation
"1HGBH41JXMN109186".vinCheckDigit       // "X"
```

## Core APIs

### String Extensions

#### `isValidVIN: Bool`
Validates the VIN according to ISO 3779 standard.

```swift
"1HGBH41JXMN109186".isValidVIN   // true
"1HGBH41JXMN109187".isValidVIN   // false (bad check digit)
"IHGBH41JXMN109186".isValidVIN   // false (contains I)
```

#### `vinInfo: VINInfo?`
Extracts comprehensive information from the VIN.

```swift
let info = "1HGBH41JXMN109186".vinInfo
// VINInfo structure with all decoded data
```

#### `vinManufacturer: String?`
Gets the manufacturer from the World Manufacturer Identifier.

```swift
"1HGBH41JXMN109186".vinManufacturer     // "Honda"
"1FTFW1ET5DFC10312".vinManufacturer     // "Ford Motor Company"
"WBAVB13516PT22180".vinManufacturer     // "BMW"
```

#### `vinModelYear: Int?`
Decodes the model year from position 10.

```swift
"1HGBH41JXMN109186".vinModelYear        // 2021 (M = 2021)
"1G1JC5444R7252367".vinModelYear        // 1994 (R = 1994)
```

#### `formattedVIN: String?`
Returns VIN with standard spacing (WMI VDS VIS).

```swift
"1HGBH41JXMN109186".formattedVIN        // "1HG BH41JX MN109186"
```

#### `vinCheckDigit: Character?`
Calculates the check digit for the VIN.

```swift
"1HGBH41JXMN109186".vinCheckDigit       // "X"
"1G1JC5444R7252367".vinCheckDigit       // "4"
```

### VINInfo Structure

```swift
struct VINInfo {
    let vin: String              // Normalized VIN
    let isValid: Bool            // Validation result
    let wmi: String              // World Manufacturer Identifier (1-3)
    let vds: String              // Vehicle Descriptor Section (4-9)
    let vis: String              // Vehicle Identifier Section (10-17)
    let manufacturer: String?    // Decoded manufacturer
    let modelYear: Int?          // Decoded model year
    let assemblyPlant: String?   // Assembly plant location
    let serialNumber: String     // Serial number (last 6)
    let region: String?          // Geographic region
    let country: String?         // Country of origin
    let vehicleType: VehicleType? // Vehicle classification
}
```

### Array Extensions

#### `validVINs: [String]`
Filters array to only valid VINs.

```swift
let vins = ["1HGBH41JXMN109186", "invalid", "1G1JC5444R7252367"]
vins.validVINs  // ["1HGBH41JXMN109186", "1G1JC5444R7252367"]
```

#### `groupedByManufacturer: [String: [String]]`
Groups VINs by manufacturer.

```swift
let vins = ["1HGBH41JXMN109186", "2HGFB2F58FH504787", "1FTFW1ET5DFC10312"]
vins.groupedByManufacturer
// ["Honda": [...], "Ford Motor Company": [...]]
```

#### `groupedByYear: [Int: [String]]`
Groups VINs by model year.

```swift
let vins = ["1HGBH41JXMN109186", "1G1JC5444R7252367"]
vins.groupedByYear
// [2021: [...], 1994: [...]]
```

#### `formattedVINs: [String]`
Returns formatted versions of all VINs.

```swift
let vins = ["1HGBH41JXMN109186", "1G1JC5444R7252367"]
vins.formattedVINs  // ["1HG BH41JX MN109186", "1G1 JC5444 R7252367"]
```

## VIN Structure

### Positions 1-3: WMI (World Manufacturer Identifier)
Identifies the manufacturer and country of origin.

| Position | Description |
|----------|-------------|
| 1 | Geographic region |
| 2 | Country |
| 3 | Manufacturer |

### Positions 4-9: VDS (Vehicle Descriptor Section)
Vehicle attributes defined by manufacturer.

| Position | Description |
|----------|-------------|
| 4-8 | Model, body type, engine, etc. |
| 9 | Check digit |

### Positions 10-17: VIS (Vehicle Identifier Section)
Unique vehicle identifier.

| Position | Description |
|----------|-------------|
| 10 | Model year |
| 11 | Assembly plant |
| 12-17 | Sequential serial number |

## Supported Manufacturers

The library supports 100+ manufacturer codes including:

### North American
- Ford Motor Company (1FA-1FM, 2FA-2FM, 3FA-3FE)
- General Motors (Chevrolet, GMC, Cadillac, Buick)
- Chrysler/Stellantis (Jeep, Dodge, Ram)
- Tesla (5YJ)

### Japanese
- Honda/Acura (1HG, 2HG, JHM, JH4)
- Toyota/Lexus (1N4, 4T1, JT2-JTN)
- Nissan/Infiniti (1N4, 3N1, JN1)
- Mazda (1YV, 4F2, JM1)
- Subaru (4S3, JF1)

### European
- BMW/Mini (WBA-WBY, WMW)
- Mercedes-Benz (WDA-WDF)
- Volkswagen Group (WVW, WAU, WP0)
- Volvo (YV1-YV3)
- Ferrari (ZFF)
- Porsche (WP0, WP1)

### Korean
- Hyundai (2HM, 5NP, KMH)
- Kia (KNA, KND, KNJ)
- Genesis (KMHG)

## Check Digit Algorithm

The VIN uses a modulo 11 weighted checksum:

1. Each character is assigned a value (A=1, B=2, etc.)
2. Each position has a weight (8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2)
3. Multiply each value by its weight
4. Sum all products
5. Modulo 11 of sum gives check digit (10 = X)

## Character Restrictions

VINs cannot contain:
- **I** - Can be confused with 1
- **O** - Can be confused with 0
- **Q** - Can be confused with 0

## Examples

### Basic VIN Validation

```swift
func validateVehicle(_ vin: String) -> Bool {
    guard vin.isValidVIN else {
        print("Invalid VIN format")
        return false
    }
    
    if let info = vin.vinInfo {
        print("Vehicle: \(info.modelYear ?? 0) \(info.manufacturer ?? "Unknown")")
        print("Country: \(info.country ?? "Unknown")")
        print("Plant: \(info.assemblyPlant ?? "Unknown")")
    }
    
    return true
}
```

### Fleet Management

```swift
func analyzeFleet(_ vins: [String]) {
    let validVINs = vins.validVINs
    let byManufacturer = validVINs.groupedByManufacturer
    let byYear = validVINs.groupedByYear
    
    print("Fleet Analysis:")
    print("Total vehicles: \(validVINs.count)")
    
    for (manufacturer, vehicles) in byManufacturer {
        print("\(manufacturer): \(vehicles.count) vehicles")
    }
    
    for (year, vehicles) in byYear.sorted(by: { $0.key > $1.key }) {
        print("\(year): \(vehicles.count) vehicles")
    }
}
```

### VIN Scanner Integration

```swift
func processScannedVIN(_ scannedText: String) {
    let cleaned = scannedText.uppercased()
        .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard cleaned.isValidVIN else {
        showError("Invalid VIN scanned")
        return
    }
    
    if let formatted = cleaned.formattedVIN {
        displayVIN(formatted)
    }
    
    if let info = cleaned.vinInfo {
        showVehicleDetails(info)
    }
}
```

### Dealer Inventory

```swift
struct Vehicle {
    let vin: String
    var info: VINInfo? { vin.vinInfo }
    
    var displayName: String {
        guard let info = info else { return "Unknown Vehicle" }
        return "\(info.modelYear ?? 0) \(info.manufacturer ?? "Unknown")"
    }
    
    var origin: String {
        info?.country ?? "Unknown"
    }
}

let inventory = [
    Vehicle(vin: "1HGBH41JXMN109186"),
    Vehicle(vin: "5YJ3E1EA5KF328931"),
]
```

## Year Decoding

Model years use a 30-year cycle:

| Code | Years | Code | Years |
|------|-------|------|-------|
| A | 1980/2010 | N | 1992/2022 |
| B | 1981/2011 | P | 1993/2023 |
| C | 1982/2012 | R | 1994/2024 |
| ... | ... | ... | ... |
| Y | 2000/2030 | 9 | 2009/2039 |

Position 7 helps determine which 30-year cycle applies.

## Performance

The library is optimized for performance:

- **Single validation**: ~0.004ms per VIN
- **Check digit calculation**: ~0.002ms per VIN
- **Full decoding**: ~0.018ms per VIN
- **Batch processing**: ~0.003ms per VIN in arrays
- **Zero allocations** for failed validations

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 13.0+

## Test Coverage

The library includes comprehensive test coverage:
- 27+ test cases
- Check digit validation
- Manufacturer detection
- Year decoding
- Edge cases (invalid characters, lengths)
- Performance benchmarks

## Limitations

- Check digit validation is only mandatory in North America
- Some manufacturers use proprietary VDS coding
- Model year detection may be ambiguous for vehicles near 30-year boundaries
- Assembly plant codes are manufacturer-specific

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

VINValidator is available under the MIT license. See LICENSE for details.

## Credits

Built with Swift best practices to provide reliable VIN validation for automotive applications.
