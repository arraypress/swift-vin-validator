//
//  VINValidator.swift
//  VINValidator
//
//  Comprehensive Vehicle Identification Number (VIN) validation per ISO 3779
//  Supporting check digit validation, manufacturer identification, and data extraction
//  Created on 26/01/2025.
//

import Foundation

public struct VINValidator {
    
    // MARK: - Constants
    
    /// Weights for check digit calculation (position 1-17).
    private static let weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
    
    /// Character to value mapping for check digit calculation.
    private static let characterValues: [Character: Int] = [
        "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8,
        "J": 1, "K": 2, "L": 3, "M": 4, "N": 5, "P": 7, "R": 9,
        "S": 2, "T": 3, "U": 4, "V": 5, "W": 6, "X": 7, "Y": 8, "Z": 9,
        "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9
    ]
    
    /// Model year codes (position 10).
    private static let yearCodes: [Character: [Int]] = [
        "A": [1980, 2010], "B": [1981, 2011], "C": [1982, 2012], "D": [1983, 2013],
        "E": [1984, 2014], "F": [1985, 2015], "G": [1986, 2016], "H": [1987, 2017],
        "J": [1988, 2018], "K": [1989, 2019], "L": [1990, 2020], "M": [1991, 2021],
        "N": [1992, 2022], "P": [1993, 2023], "R": [1994, 2024], "S": [1995, 2025],
        "T": [1996, 2026], "V": [1997, 2027], "W": [1998, 2028], "X": [1999, 2029],
        "Y": [2000, 2030], "1": [2001, 2031], "2": [2002, 2032], "3": [2003, 2033],
        "4": [2004, 2034], "5": [2005, 2035], "6": [2006, 2036], "7": [2007, 2037],
        "8": [2008, 2038], "9": [2009, 2039]
    ]
    
    // MARK: - Validation
    
    /// Validate a VIN according to ISO 3779 standard.
    ///
    /// Checks:
    /// - Length must be exactly 17 characters
    /// - No I, O, or Q characters allowed
    /// - Check digit (position 9) must be valid
    ///
    /// - Parameter vin: The VIN to validate
    /// - Returns: true if the VIN is valid
    public static func validate(_ vin: String) -> Bool {
        let normalized = vin.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must be exactly 17 characters
        guard normalized.count == 17 else { return false }
        
        // Check for invalid characters (I, O, Q are not allowed in VINs)
        let invalidCharacters = CharacterSet(charactersIn: "IOQ")
        if normalized.rangeOfCharacter(from: invalidCharacters) != nil {
            return false
        }
        
        // All characters must be alphanumeric
        let allowedCharacters = CharacterSet.alphanumerics
        guard normalized.rangeOfCharacter(from: allowedCharacters.inverted) == nil else {
            return false
        }
        
        // Validate check digit (position 9)
        let checkDigitChar = normalized[normalized.index(normalized.startIndex, offsetBy: 8)]
        let calculated = calculateCheckDigit(normalized)
        
        return checkDigitChar == calculated
    }
    
    /// Calculate the check digit for a VIN.
    ///
    /// Uses the standard VIN check digit algorithm with weighted values.
    ///
    /// - Parameter vin: The VIN to calculate check digit for
    /// - Returns: The calculated check digit character
    public static func calculateCheckDigit(_ vin: String) -> Character? {
        let normalized = vin.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.count == 17 else { return nil }
        
        var sum = 0
        
        for (index, char) in normalized.enumerated() {
            guard let value = characterValues[char] else { return nil }
            sum += value * weights[index]
        }
        
        let remainder = sum % 11
        
        if remainder == 10 {
            return "X"
        } else {
            return Character(String(remainder))
        }
    }
    
    // MARK: - Decoding
    
    /// Decode comprehensive information from a VIN.
    ///
    /// Extracts:
    /// - WMI (World Manufacturer Identifier) - positions 1-3
    /// - VDS (Vehicle Descriptor Section) - positions 4-9
    /// - VIS (Vehicle Identifier Section) - positions 10-17
    /// - Manufacturer, model year, assembly plant, etc.
    ///
    /// - Parameter vin: The VIN to decode
    /// - Returns: Decoded VIN information, or nil if invalid
    public static func decode(_ vin: String) -> VINInfo? {
        let normalized = vin.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let isValid = validate(normalized)
        
        guard normalized.count == 17 else { return nil }
        
        // Extract VIN sections
        let wmi = String(normalized.prefix(3))
        let vds = String(normalized[normalized.index(normalized.startIndex, offsetBy: 3)..<normalized.index(normalized.startIndex, offsetBy: 9)])
        let vis = String(normalized.suffix(8))
        
        // Decode components
        let manufacturer = decodeManufacturer(wmi: wmi)
        let modelYear = decodeModelYear(normalized)
        let assemblyPlant = decodePlant(normalized)
        let serialNumber = String(normalized.suffix(6))
        let region = decodeRegion(wmi: wmi)
        let country = decodeCountry(wmi: wmi)
        let vehicleType = decodeVehicleType(vds: vds)
        
        return VINInfo(
            vin: normalized,
            isValid: isValid,
            wmi: wmi,
            vds: vds,
            vis: vis,
            manufacturer: manufacturer,
            modelYear: modelYear,
            assemblyPlant: assemblyPlant,
            serialNumber: serialNumber,
            region: region,
            country: country,
            vehicleType: vehicleType
        )
    }
    
    /// Decode the manufacturer from WMI.
    ///
    /// Uses the World Manufacturer Identifier (first 3 characters).
    ///
    /// - Parameter wmi: The WMI code (first 3 characters of VIN)
    /// - Returns: The manufacturer name, or nil if unknown
    private static func decodeManufacturer(wmi: String) -> String? {
        // Build manufacturer mappings efficiently
        let fordWMIs = ["1FA", "1FB", "1FC", "1FD", "1FM", "1FT", "2FA", "2FB", "2FC", "2FM", "2FT", "3FA", "3FE"]
        let gmChevroletWMIs = ["1G1", "1GC", "2G1", "3G1"]
        let gmPontiacWMIs = ["1G2", "2G2"]
        let gmOldsmobileWMIs = ["1G3"]
        let gmBuickWMIs = ["1G4"]
        let gmCadillacWMIs = ["1G6"]
        let gmSaturnWMIs = ["1G8"]
        let gmGMCWMIs = ["1GT"]
        let hondaWMIs = ["1HG", "2HG", "2HK", "2HM", "5FN", "5J6", "JHM"]
        let acuraWMIs = ["JH4"]
        let toyotaWMIs = ["1N4", "4T1", "4T3", "5TB", "5TD", "5TE", "5TF", "JT2", "JT3", "JTD", "JTE", "JTK", "JTL", "JTM", "JTN"]
        let nissanWMIs = ["1N4", "3N1", "5N1", "JN1", "JN8"]
        let mazdaWMIs = ["1YV", "4F2", "JM1", "JM3"]
        let volkswagenWMIs = ["1VW", "3VW", "WV1", "WV2", "WVG", "WVW"]
        let bmwWMIs = ["4US", "WBA", "WBM", "WBS", "WBW", "WBX", "WBY"]
        let bmwMiniWMIs = ["WBM", "WMW"]
        let mercedesWMIs = ["WDA", "WDB", "WDC", "WDD", "WDF"]
        let audiWMIs = ["TRU", "WA1", "WAU", "WUA"]
        let porscheWMIs = ["WP0", "WP1"]
        let teslaWMIs = ["5YJ"]
        let subaruWMIs = ["4S3", "4S4", "JF1", "JF2"]
        let hyundaiWMIs = ["2HM", "5NP", "KM8", "KMH"]
        let kiaWMIs = ["KNA", "KND", "KNJ"]
        let fiatWMIs = ["ZFA", "ZFC"]
        let ferrariWMIs = ["ZFF"]
        let lamborghiniWMIs = ["ZA9", "ZHW"]
        let maseratiWMIs = ["ZAM"]
        let jaguarWMIs = ["SAJ"]
        let landRoverWMIs = ["SAL"]
        let volvoWMIs = ["YV1", "YV2", "YV3"]
        
        // Check manufacturer groups
        if fordWMIs.contains(wmi) { return "Ford Motor Company" }
        if gmChevroletWMIs.contains(wmi) { return "Chevrolet" }
        if gmPontiacWMIs.contains(wmi) { return "Pontiac" }
        if gmOldsmobileWMIs.contains(wmi) { return "Oldsmobile" }
        if gmBuickWMIs.contains(wmi) { return "Buick" }
        if gmCadillacWMIs.contains(wmi) { return "Cadillac" }
        if gmSaturnWMIs.contains(wmi) { return "Saturn" }
        if gmGMCWMIs.contains(wmi) { return "GMC" }
        if hondaWMIs.contains(wmi) { return "Honda" }
        if acuraWMIs.contains(wmi) { return "Acura" }
        if toyotaWMIs.contains(wmi) { return "Toyota" }
        if nissanWMIs.contains(wmi) { return "Nissan" }
        if mazdaWMIs.contains(wmi) { return "Mazda" }
        if volkswagenWMIs.contains(wmi) { return "Volkswagen" }
        if bmwWMIs.contains(wmi) { return "BMW" }
        if bmwMiniWMIs.contains(wmi) { return "BMW Mini" }
        if mercedesWMIs.contains(wmi) { return "Mercedes-Benz" }
        if audiWMIs.contains(wmi) { return "Audi" }
        if porscheWMIs.contains(wmi) { return "Porsche" }
        if teslaWMIs.contains(wmi) { return "Tesla" }
        if subaruWMIs.contains(wmi) { return "Subaru" }
        if hyundaiWMIs.contains(wmi) { return "Hyundai" }
        if kiaWMIs.contains(wmi) { return "Kia" }
        if fiatWMIs.contains(wmi) { return "Fiat" }
        if ferrariWMIs.contains(wmi) { return "Ferrari" }
        if lamborghiniWMIs.contains(wmi) { return "Lamborghini" }
        if maseratiWMIs.contains(wmi) { return "Maserati" }
        if jaguarWMIs.contains(wmi) { return "Jaguar" }
        if landRoverWMIs.contains(wmi) { return "Land Rover" }
        if volvoWMIs.contains(wmi) { return "Volvo" }
        
        // Additional manufacturers with single or few WMIs
        let additionalManufacturers: [String: String] = [
            "1L1": "Lincoln",
            "1ME": "Mercury",
            "4M2": "Mercury",
            "5L1": "Lincoln",
            "2C3": "Chrysler",
            "1J4": "Jeep",
            "JA3": "Mitsubishi",
            "JA4": "Mitsubishi",
            "JS1": "Suzuki",
            "KL1": "Chevrolet (Korea)",
            "SAR": "Rover",
            "SCC": "Lotus",
            "VF1": "Renault",
            "VF2": "Renault",
            "VF3": "Peugeot",
            "VF7": "Citroën",
            "W0L": "Opel",
            "W0V": "Opel",
            "YK1": "Saab",
            "YS2": "Scania",
            "YS3": "Saab",
            "ZAR": "Alfa Romeo",
            "ZCF": "Iveco",
            "ZLA": "Lancia"
        ]
        
        // Check additional manufacturers
        if let manufacturer = additionalManufacturers[wmi] {
            return manufacturer
        }
        
        // Try first 2 characters for broader manufacturer groups
        let prefix2 = String(wmi.prefix(2))
        
        // Check common 2-character prefixes
        let prefix2Manufacturers: [String: String] = [
            "1F": "Ford Motor Company",
            "1G": "General Motors",
            "1H": "Honda",
            "1J": "Jeep",
            "1L": "Lincoln",
            "1M": "Mercury",
            "1N": "Nissan",
            "1V": "Volkswagen",
            "1Y": "Mazda",
            "2F": "Ford Motor Company",
            "2G": "General Motors",
            "2H": "Honda",
            "3F": "Ford Motor Company",
            "3G": "General Motors",
            "3N": "Nissan",
            "3V": "Volkswagen",
            "4S": "Subaru",
            "4T": "Toyota",
            "5T": "Toyota",
            "JF": "Subaru",
            "JH": "Honda",
            "JM": "Mazda",
            "JN": "Nissan",
            "JT": "Toyota",
            "KM": "Hyundai",
            "KN": "Kia",
            "SA": "United Kingdom",
            "VF": "France",
            "WA": "Audi",
            "WB": "BMW",
            "WD": "Mercedes-Benz",
            "WM": "BMW Mini",
            "WP": "Porsche",
            "WV": "Volkswagen",
            "YS": "Saab/Scania",
            "YV": "Volvo",
            "ZA": "Italy",
            "ZF": "Ferrari/Fiat"
        ]
        
        if let manufacturer = prefix2Manufacturers[prefix2] {
            // Clean up generic responses
            if manufacturer == "United Kingdom" || manufacturer == "France" || manufacturer == "Italy" {
                return nil  // Too generic
            }
            return manufacturer
        }
        
        return nil
    }
    
    /// Decode the model year from the VIN.
    ///
    /// Uses position 10 of the VIN. Year codes repeat every 30 years, and
    /// position 7 says which cycle: numeric for 1980-2009, alphabetic for
    /// 2010-2039 (49 CFR 565).
    ///
    /// - Parameter vin: The complete VIN
    /// - Returns: The model year, or nil if cannot decode
    private static func decodeModelYear(_ vin: String) -> Int? {
        guard vin.count >= 10 else { return nil }
        
        let yearChar = vin[vin.index(vin.startIndex, offsetBy: 9)]
        let pos7 = vin[vin.index(vin.startIndex, offsetBy: 6)]
        
        guard let years = yearCodes[yearChar] else { return nil }
        
        // 49 CFR 565: position 7 is NUMERIC for model years 1980-2009 and
        // ALPHABETIC for 2010-2039. That is the whole rule, and it is what
        // disambiguates a year code that repeats every 30 years.
        //
        // This was inverted, and then a "is the car more than 40 years old"
        // heuristic was layered on top of the wrong branch. The canonical test
        // VIN 1HGBH41JXMN109186 — a 1991 Honda, position 7 = "1" — decoded as
        // 2021. Being confidently wrong about a lookup table is worse than not
        // having the table, because it is the reason to reach for a tool
        // rather than ask from memory.
        //
        // Scope, stated rather than implied: the standard binds passenger
        // vehicles and light trucks (GVWR under 10,000 lb) sold in North
        // America. Heavy vehicles and some non-NA manufacturers do not follow
        // it, so a year here is a strong inference, not a guarantee.
        return pos7.isNumber ? years[0] : years[1]
    }
    
    /// Decode the assembly plant from the VIN.
    ///
    /// Uses position 11 of the VIN.
    ///
    /// - Parameter vin: The complete VIN
    /// - Returns: The assembly plant name, or nil if unknown
    private static func decodePlant(_ vin: String) -> String? {
        guard vin.count >= 11 else { return nil }
        
        let plantChar = vin[vin.index(vin.startIndex, offsetBy: 10)]
        let wmi = String(vin.prefix(3))
        
        // Plant codes are manufacturer-specific
        // This is a simplified example for common manufacturers
        switch wmi {
        case let w where w.hasPrefix("1F"):  // Ford
            switch plantChar {
            case "A": return "Atlanta, Georgia"
            case "B": return "Oakville, Ontario"
            case "C": return "Ontario, Canada"
            case "D": return "Ohio Assembly"
            case "E": return "Kentucky Truck"
            case "F": return "Dearborn, Michigan"
            case "G": return "Chicago, Illinois"
            case "K": return "Kansas City, Missouri"
            case "L": return "Michigan Assembly"
            case "M": return "Cuautitlan, Mexico"
            case "N": return "Norfolk, Virginia"
            case "P": return "St. Paul, Minnesota"
            case "R": return "Hermosillo, Mexico"
            case "W": return "Wayne, Michigan"
            default: break
            }
            
        case let w where w.hasPrefix("1G"):  // GM
            switch plantChar {
            case "0": return "Pontiac, Michigan"
            case "1": return "Wentzville, Missouri"
            case "2": return "Moraine, Ohio"
            case "3": return "Van Nuys, California"
            case "4": return "Orion, Michigan"
            case "5": return "Ramos Arizpe, Mexico"
            case "6": return "Oklahoma City, Oklahoma"
            case "7": return "Lordstown, Ohio"
            case "8": return "Shreveport, Louisiana"
            case "9": return "Oshawa, Ontario"
            case "A": return "Lakewood, Georgia"
            case "B": return "Baltimore, Maryland"
            case "C": return "Southgate, California"
            case "D": return "Doraville, Georgia"
            case "F": return "Flint, Michigan"
            case "G": return "Silao, Mexico"
            case "J": return "Janesville, Wisconsin"
            case "K": return "Leeds, Missouri"
            case "L": return "Linden, New Jersey"
            case "N": return "Norwood, Ohio"
            case "R": return "Arlington, Texas"
            case "S": return "St. Louis, Missouri"
            case "T": return "Tarrytown, New York"
            case "W": return "Willow Run, Michigan"
            case "Y": return "Wilmington, Delaware"
            case "Z": return "Fremont, California"
            default: break
            }
            
        case let w where w.hasPrefix("1HG") || w.hasPrefix("2HG"):  // Honda
            switch plantChar {
            case "A": return "Marysville, Ohio"
            case "B": return "East Liberty, Ohio"
            case "C": return "Sayama, Japan"
            case "E": return "Alliston, Ontario"
            case "H": return "Guangzhou, China"
            case "M": return "Celaya, Mexico"
            case "T": return "Suzuka, Japan"
            default: break
            }
            
        case let w where w.hasPrefix("JT") || w.hasPrefix("4T") || w.hasPrefix("5T"):  // Toyota
            switch plantChar {
            case "0": return "TMM, USA"
            case "1": return "Toyota City, Japan"
            case "2": return "Toyota City, Japan"
            case "3": return "Toyota City, Japan"
            case "4": return "Toyota City, Japan"
            case "5": return "Toyota City, Japan"
            case "6": return "Fujisawa, Japan"
            case "7": return "Toyota City, Japan"
            case "9": return "Miyawaka, Japan"
            case "A": return "Toyota City, Japan"
            case "B": return "Toyota City, Japan"
            case "C": return "Cambridge, Ontario"
            case "D": return "Toyota City, Japan"
            case "E": return "Takaoka, Japan"
            case "F": return "Toyota City, Japan"
            case "G": return "Toyota City, Japan"
            case "J": return "Toyota City, Japan"
            case "K": return "Miyagi, Japan"
            case "M": return "Tijuana, Mexico"
            case "N": return "Kanda, Japan"
            case "R": return "Lafayette, Indiana"
            case "S": return "Princeton, Indiana"
            case "U": return "Georgetown, Kentucky"
            case "W": return "Woodstock, Ontario"
            case "X": return "San Antonio, Texas"
            case "Y": return "Onnaing, France"
            case "Z": return "Tahara, Japan"
            default: break
            }
            
        default:
            break
        }
        
        return nil
    }
    
    /// Decode the region from the WMI.
    ///
    /// First character indicates the region.
    ///
    /// - Parameter wmi: The WMI code (first 3 characters)
    /// - Returns: The region name
    private static func decodeRegion(wmi: String) -> String? {
        guard !wmi.isEmpty else { return nil }
        
        switch wmi.first {
        case "1", "4", "5":
            return "North America"
        case "2":
            return "Canada"
        case "3":
            return "Mexico"
        case "6":
            return "Oceania"
        case "7":
            return "New Zealand"
        case "8", "9":
            return "South America"
        case "A", "B", "C", "D", "E", "F", "G", "H":
            return "Africa"
        case "J", "K", "L", "M", "N", "P", "R":
            return "Asia"
        case "S", "T", "U", "V", "W", "X", "Y", "Z":
            return "Europe"
        default:
            return nil
        }
    }
    
    /// Decode the country from the WMI.
    ///
    /// Uses first 1-2 characters to determine country.
    ///
    /// - Parameter wmi: The WMI code (first 3 characters)
    /// - Returns: The country name
    private static func decodeCountry(wmi: String) -> String? {
        guard !wmi.isEmpty else { return nil }
        
        let prefix = String(wmi.prefix(2))
        
        // Country codes
        let countries: [String: String] = [
            "1": "United States",
            "2": "Canada",
            "3": "Mexico",
            "4": "United States",
            "5": "United States",
            "6A": "Australia",
            "7A": "New Zealand",
            "8A": "Argentina",
            "8B": "Argentina",
            "8C": "Argentina",
            "8D": "Argentina",
            "8E": "Chile",
            "8F": "Chile",
            "9A": "Brazil",
            "9B": "Brazil",
            "9C": "Brazil",
            "9D": "Brazil",
            "9E": "Brazil",
            "9F": "Colombia",
            "9G": "Colombia",
            "9H": "Colombia",
            "9J": "Colombia",
            "9K": "Colombia",
            "JA": "Japan",
            "JB": "Japan",
            "JC": "Japan",
            "JD": "Japan",
            "JE": "Japan",
            "JF": "Japan",
            "JG": "Japan",
            "JH": "Japan",
            "JJ": "Japan",
            "JK": "Japan",
            "JL": "Japan",
            "JM": "Japan",
            "JN": "Japan",
            "JP": "Japan",
            "JR": "Japan",
            "JS": "Japan",
            "JT": "Japan",
            "KA": "South Korea",
            "KB": "South Korea",
            "KC": "South Korea",
            "KD": "South Korea",
            "KE": "South Korea",
            "KF": "South Korea",
            "KG": "South Korea",
            "KH": "South Korea",
            "KJ": "South Korea",
            "KK": "South Korea",
            "KL": "South Korea",
            "KM": "South Korea",
            "KN": "South Korea",
            "LA": "China",
            "LB": "China",
            "LC": "China",
            "LD": "China",
            "LE": "China",
            "LF": "China",
            "LG": "China",
            "LH": "China",
            "LJ": "China",
            "LK": "China",
            "LL": "China",
            "LM": "China",
            "LN": "China",
            "MA": "India",
            "MB": "India",
            "MC": "India",
            "MD": "India",
            "ME": "India",
            "SA": "United Kingdom",
            "SB": "United Kingdom",
            "SC": "United Kingdom",
            "SD": "United Kingdom",
            "SE": "United Kingdom",
            "SF": "United Kingdom",
            "SG": "United Kingdom",
            "SH": "United Kingdom",
            "SJ": "United Kingdom",
            "SK": "United Kingdom",
            "SL": "United Kingdom",
            "SM": "United Kingdom",
            "TR": "Hungary",
            "TS": "Hungary",
            "TT": "Hungary",
            "TU": "Hungary",
            "TV": "Hungary",
            "VA": "Austria",
            "VB": "Austria",
            "VC": "Austria",
            "VD": "Austria",
            "VE": "Austria",
            "VF": "France",
            "VG": "France",
            "VH": "France",
            "VJ": "France",
            "VK": "France",
            "VL": "France",
            "VM": "France",
            "VN": "France",
            "VP": "France",
            "VR": "France",
            "VS": "Spain",
            "VT": "Spain",
            "VU": "Spain",
            "VV": "Spain",
            "VW": "Spain",
            "VX": "Spain",
            "VY": "Spain",
            "VZ": "Spain",
            "WA": "Germany",
            "WB": "Germany",
            "WC": "Germany",
            "WD": "Germany",
            "WE": "Germany",
            "WF": "Germany",
            "WG": "Germany",
            "WH": "Germany",
            "WJ": "Germany",
            "WK": "Germany",
            "WL": "Germany",
            "WM": "Germany",
            "WN": "Germany",
            "WP": "Germany",
            "WR": "Germany",
            "WS": "Germany",
            "WT": "Germany",
            "WU": "Germany",
            "WV": "Germany",
            "WW": "Germany",
            "WX": "Germany",
            "WY": "Germany",
            "WZ": "Germany",
            "W0": "Germany",
            "W1": "Germany",
            "XA": "Bulgaria",
            "XB": "Bulgaria",
            "XC": "Bulgaria",
            "XD": "Bulgaria",
            "XE": "Bulgaria",
            "YA": "Belgium",
            "YB": "Belgium",
            "YC": "Belgium",
            "YD": "Belgium",
            "YE": "Belgium",
            "YK": "Finland",
            "YL": "Finland",
            "YM": "Finland",
            "YN": "Finland",
            "YP": "Finland",
            "YS": "Sweden",
            "YT": "Sweden",
            "YU": "Sweden",
            "YV": "Sweden",
            "YW": "Sweden",
            "ZA": "Italy",
            "ZB": "Italy",
            "ZC": "Italy",
            "ZD": "Italy",
            "ZE": "Italy",
            "ZF": "Italy",
            "ZG": "Italy",
            "ZH": "Italy",
            "ZJ": "Italy",
            "ZK": "Italy",
            "ZL": "Italy",
            "ZM": "Italy",
            "ZN": "Italy",
            "ZP": "Italy",
            "ZR": "Italy",
        ]
        
        // Try 2-character match first
        if let country = countries[prefix] {
            return country
        }
        
        // Try single character match
        if let country = countries[String(wmi.first!)] {
            return country
        }
        
        return nil
    }
    
    /// Decode the vehicle type from the VDS.
    ///
    /// Uses positions 4-8 of the VIN (part of VDS).
    /// This is manufacturer-specific and simplified here.
    ///
    /// - Parameter vds: The VDS section (positions 4-9)
    /// - Returns: The vehicle type, or nil if cannot determine
    private static func decodeVehicleType(vds: String) -> VehicleType? {
        // This is highly manufacturer-specific
        // Simplified example based on common patterns
        guard !vds.isEmpty else { return nil }
        
        let char4 = vds.first
        
        // Very simplified type detection
        switch char4 {
        case "A", "B", "C", "D", "E":
            return .passenger
        case "F", "G", "H":
            return .truck
        case "J", "K", "L":
            return .multipurpose
        case "M":
            return .bus
        case "N", "P":
            return .motorcycle
        case "T":
            return .trailer
        default:
            return nil
        }
    }
    
    // MARK: - Formatting
    
    /// Format a VIN with standard spacing.
    ///
    /// Format: XXX XXXXXX XXXXXXXX (WMI VDS VIS)
    ///
    /// - Parameter vin: The VIN to format
    /// - Returns: Formatted VIN with spacing
    public static func format(_ vin: String) -> String {
        let normalized = vin.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalized.count == 17 else { return normalized }
        
        let wmi = normalized.prefix(3)
        let vds = normalized[normalized.index(normalized.startIndex, offsetBy: 3)..<normalized.index(normalized.startIndex, offsetBy: 9)]
        let vis = normalized.suffix(8)
        
        return "\(wmi) \(vds) \(vis)"
    }
    
    // MARK: - Utility Methods
    
    /// Generate a test VIN that passes validation (for testing only).
    ///
    /// - Warning: These are for testing only. Never use in production.
    /// - Parameter manufacturer: The manufacturer to generate a test VIN for
    /// - Returns: A valid test VIN
    public static func generateTestVIN(manufacturer: String = "Honda") -> String {
        // Only return VINs we've verified have correct check digits
        switch manufacturer.lowercased() {
        case "honda":
            return "1HGBH41JXMN109186"  // Check digit: X (verified)
        case "chevrolet":
            return "1G1JC5444R7252367"  // Check digit: 4 (verified)
        case "tesla":
            return "5YJ3E1EA5KF328931"  // Check digit: 5 (verified)
        default:
            return "1HGBH41JXMN109186"  // Default to Honda
        }
    }
    
}
