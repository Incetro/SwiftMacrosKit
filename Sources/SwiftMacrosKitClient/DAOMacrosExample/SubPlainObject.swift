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
    
    func translate(from plain: SubPlainObject, to databaseModel: SubPlainObject.DatabaseModel) throws {
        if databaseModel.uniqueId.isEmpty {
            databaseModel.uniqueId = plain.uniqueId.rawValue
        }
        databaseModel.id = plain.id
        databaseModel.optionalString = plain.optionalString
        databaseModel.string = plain.string
        databaseModel.double = plain.double
        databaseModel.optionalDouble.value = plain.optionalDouble
        databaseModel.url = plain.url.absoluteString
        databaseModel.optionalUrl = plain.optionalUrl?.absoluteString
        databaseModel.date = plain.date
        databaseModel.optionalDate = plain.optionalDate
        databaseModel.int = plain.int
        databaseModel.optionalInt.value = plain.optionalInt
        databaseModel.intEnum.value = plain.intEnum.rawValue
        databaseModel.intEnumOptional.value = plain.intEnumOptional?.rawValue
        databaseModel.intEnumArray.removeAll()
        databaseModel.intEnumArray.append(objectsIn: plain.intEnumArray.compactMap({
                    $0.rawValue
                }))
        databaseModel.intEnumArrayOptional.removeAll()
        databaseModel.intEnumArrayOptional.append(objectsIn: plain.intEnumArrayOptional?.compactMap({
                    $0.rawValue
                }) ?? [])
        databaseModel.stringEnum = plain.stringEnum.rawValue
        databaseModel.stringEnumOptional = plain.stringEnumOptional?.rawValue
        databaseModel.stringEnumArray.removeAll()
        databaseModel.stringEnumArray.append(objectsIn: plain.stringEnumArray.compactMap({
                    $0.rawValue
                }))
        databaseModel.stringEnumOptionalArray.removeAll()
        databaseModel.stringEnumOptionalArray.append(objectsIn: plain.stringEnumOptionalArray?.compactMap({
                    $0.rawValue
                }) ?? [])
    }
}
