//
//  MainPlainObject.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 13.01.2025.
//

import SDAO
import Foundation
import RealmSwift
import SwiftMacrosKit
import Monreau

// MARK: - MainPlainObject

@DAOPlain
public struct MainPlainObject: Equatable, Codable {
    
    public var uniqueId: UniqueID {
        UniqueID(rawValue: id)
    }
    
    public static let staticVariable = "staticVariable"
    
    // MARK: - Primitive
    
    public let id: String
    public let optionalString: String?
    public let string: String
    public let double: Double
    public let optionalDouble: Double?
    public let description: String
    public let url: URL
    public let optionalUrl: URL?
    public let date: Date
    public let optionalDate: Date?
    public let int: Int
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
    
    // MARK: - OtherPlain
    
    /// @dao-plain
    public let plain: SubPlainObject
    
    /// @dao-plain
    public let optionalPlain: SubPlainObject?
    
    /// @dao-plain
    public let plainArray: [SubPlainObject]
    
    /// @dao-plain
    public let optionalPlainArray: [SubPlainObject]?
}
