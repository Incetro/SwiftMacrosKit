//
//  SubPlainObject.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 13.01.2025.
//

import SDAO
import RealmSwift
import Foundation
import SwiftMacrosKit
import Monreau

// MARK: - SubPlainObject

@DAOPlain
public struct SubPlainObject: Equatable, Codable {
    
    // MARK: - MustBeIngored

    public var uniqueId: UniqueID {
        UniqueID(value: id)
    }
    
    public static let someStaticProperty = 0
    
    public var someComputedProperty: Int {
        int
    }
    
    /// @dao-ignore
    public var ignoredComputedProperty: Int {
        0
    }
    
    public func someMethod() -> Int {
        0
    }
    
    public static func someStaticMethod() -> Int {
        0
    }
    
    // MARK: - Primitive
    
    public let id: Int
    public let optionalString: String?
    public var string: String
    public let stringArray: [String]
    public let double: Double
    public let doubleArray: [Double]
    public let optionalDouble: Double?
    public let url: URL
    public let urlArray: [URL]
    public let optionalUrl: URL?
    public var date: Date
    public let optionalDate: Date?
    public let int: Int
    public let intArray: [Int]
    public let optionalInt: Int?
    
    // MARK: - IntEnum

    /// @dao-int-enum
    public let intEnum: IntEnum
    
    /// @dao-int-enum
    public let intEnumOptional: IntEnum?
    
    /// @dao-int-enum
    public let intEnumArray: [IntEnum]
    
    /// @dao-int-enum
    public let intEnumArrayOptional: [IntEnum]?

    // MARK: - StringEnum

    /// @dao-string-enum
    public let stringEnum: StringEnum
    
    /// @dao-string-enum
    public let stringEnumOptional: StringEnum?
    
    /// @dao-string-enum
    /// Come comment
    public let stringEnumArray: [StringEnum]
    
    /// @dao-string-enum
    public let stringEnumOptionalArray: [StringEnum]?
}
