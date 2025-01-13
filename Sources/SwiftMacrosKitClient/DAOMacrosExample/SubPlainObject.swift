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

// MARK: - SubPlainObject

@DAOMacro
public struct SubPlainObject: Equatable, Codable {

    public var uniqueId: UniqueID {
        UniqueID(value: id)
    }
    // MARK: - Primitive
    
    public let id: Int
    public let optionalString: String?
    public let string: String
    public let double: Double
    public let optionalDouble: Double?
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
}
