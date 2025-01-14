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
}

func a(model: SubPlainObject.DatabaseModel) -> SubPlainObject {
    SubPlainObject(
        id: model.id,
        optionalString: model.optionalString ?? "",
        string: model.string,
        double: model.double,
        optionalDouble: model.optionalDouble.value ?? 0,
        url: URL(string: model.url).unsafelyUnwrapped, // here
        optionalUrl: URL(string: model.optionalUrl ?? "").unsafelyUnwrapped, // here
        date: model.date,
        optionalDate: model.optionalDate ?? Date(),
        int: model.int,
        optionalInt: model.optionalInt.value ?? 0,
        intEnum: IntEnum(rawValue: model.intEnum.value ?? 0) ?? .case1, // here
        intEnumOptional: IntEnum(rawValue: model.intEnumOptional.value ?? 0), // here
        intEnumArray: model.intEnumArray.compactMap({ // here
                IntEnum(rawValue: $0)
            }),
        intEnumArrayOptional: model.intEnumArrayOptional.compactMap({
                IntEnum(rawValue: $0)
            }),
        stringEnum: StringEnum(rawValue: model.stringEnum ?? "").unsafelyUnwrapped, // here
        stringEnumOptional: StringEnum(rawValue: model.stringEnumOptional ?? ""),
        stringEnumArray: model.stringEnumArray.compactMap({
                StringEnum(rawValue: $0)
            }),
        stringEnumOptionalArray: model.stringEnumOptionalArray.compactMap({
                StringEnum(rawValue: $0)
            })
    )
}
