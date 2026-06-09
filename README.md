# Swift VIN Validator

A lightweight Swift library for validating and decoding Vehicle Identification Numbers (VINs) per the ISO 3779 standard. It verifies the check digit, identifies the manufacturer from the World Manufacturer Identifier, decodes the model year and assembly plant, and breaks the VIN into its WMI/VDS/VIS sections — all offline with zero dependencies.

## Features

- 🎯 **ISO 3779 validation** — enforces 17-character length, rejects forbidden `I`/`O`/`Q`, and requires alphanumeric characters
- 🔢 **Check digit verification** — computes the position-9 check digit using the weighted-value algorithm
- 🏭 **Manufacturer identification** — resolves the WMI to a manufacturer (Ford, GM brands, Honda, Toyota, BMW, Tesla, and many more), with two-character prefix fallbacks
- 📅 **Model year decoding** — derives the year from position 10, using position 7 to disambiguate the 30-year cycle
- 🏗️ **Assembly plant lookup** — decodes manufacturer-specific plant codes from position 11
- 🧩 **Section breakdown** — splits the VIN into WMI (1–3), VDS (4–9), and VIS (10–17), plus the serial number
- 🌍 **Region & country** — derives region and country from the WMI
- 🚗 **Vehicle type** — infers a `VehicleType` from the descriptor section
- ✨ **Formatting** — re-spaces a VIN into readable `XXX XXXXXX XXXXXXXX` groups
- 🧰 **String conveniences** — `isValidVIN`, `vinInfo`, `vinManufacturer`, `vinModelYear`, `vinCheckDigit`, `formattedVIN` directly on `String`
- 📦 **Array helpers** — filter to valid VINs and group collections by manufacturer or model year
- 🔒 **Sendable models** — `VINInfo` and `VehicleType` are `Sendable` for safe concurrent use

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 6.1+
- Xcode 26.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-vin-validator.git", from: "1.0.0")
]
```

## Usage

### Validating a VIN

```swift
import VINValidator

VINValidator.validate("1HGBH41JXMN109186")   // true / false based on check digit
"1HGBH41JXMN109186".isValidVIN                // same, on String

// Inspect the calculated check digit (position 9)
"1HGBH41JXMN109186".vinCheckDigit             // e.g. "X"
```

### Decoding a VIN

```swift
import VINValidator

if let info = "1HGBH41JXMN109186".vinInfo {
    print(info.manufacturer)    // "Honda"
    print(info.modelYear)       // decoded model year
    print(info.wmi)             // "1HG"
    print(info.vds)             // positions 4–9
    print(info.vis)             // positions 10–17
    print(info.serialNumber)    // last 6 characters
    print(info.region)          // decoded region
    print(info.country)         // decoded country
    print(info.vehicleType)     // .passenger, .truck, ...
    print(info.isValid)         // check-digit validity
}

// Or via the static API
let info = VINValidator.decode("1HGBH41JXMN109186")
```

### Quick accessors and formatting

```swift
import VINValidator

"1HGBH41JXMN109186".vinManufacturer   // "Honda"
"1HGBH41JXMN109186".vinModelYear      // model year
"1HGBH41JXMN109186".formattedVIN      // "1HG BH41JX MN109186"
```

### Working with collections

```swift
import VINValidator

let vins = ["1HGBH41JXMN109186", "5YJ3E1EA7KF000000", "not a vin"]

vins.validVINs               // only valid VINs
vins.groupedByManufacturer   // ["Honda": [...], "Tesla": [...]]
vins.groupedByYear           // [Int: [String]] keyed by model year
vins.formattedVINs           // all formatted with section spacing
```

## How It Works

Validation normalises the input (uppercase, trimmed), confirms it is exactly 17 alphanumeric characters with no `I`/`O`/`Q`, then recomputes the check digit: each character maps to a numeric value, is multiplied by its positional weight, the products are summed, and the result mod 11 yields the expected digit (`10` becomes `X`). A VIN is valid only when the computed digit matches position 9.

Decoding always splits the VIN into its sections and resolves the manufacturer, year, plant, region, country, and vehicle type from lookup tables — `VINInfo.isValid` reports whether the check digit also passed. Manufacturer resolution tries exact WMIs first, then a curated single-WMI map, then two-character prefixes (discarding overly generic country-only matches). Model-year decoding uses position 7 to choose between the two years each position-10 letter can represent.

## Models

| Type | Description |
|------|-------------|
| `VINInfo` | Struct with `vin`, `isValid`, `wmi`, `vds`, `vis`, `manufacturer`, `modelYear`, `assemblyPlant`, `serialNumber`, `region`, `country`, `vehicleType` |
| `VehicleType` | Enum: `.passenger`, `.truck`, `.multipurpose`, `.bus`, `.motorcycle`, `.trailer`, `.incomplete` |

## Use Cases

- Validating VINs entered in forms before submission
- Decoding manufacturer and year from a VIN for display or filtering
- Grouping fleets or listings by manufacturer or model year
- Sanity-checking imported VIN datasets

## Testing

```bash
swift test
```

The test suite covers check-digit validation, manufacturer and year decoding, section extraction, formatting, and the String/Array conveniences.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
