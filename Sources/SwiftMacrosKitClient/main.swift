import SwiftMacrosKit
import SwiftUI

// MARK: - DynamicStringWrapper+Example

@DynamicStringWrapper
public struct SomeStruct {
    
    public var someString: String
}

// MARK: - WithLocalizationUpdater+Example

@WithLocalizationUpdater
public struct SomeView: View {
    
    public var body: some View {
        Text("Hello world!")
    }
}

// MARK: - ClosureAccessor+Example

@ClosureAccessor
public var someVariable: Int
public func someVariableClosure() -> Int {
    0
}

// MARK: - AutoInit+Example

@AutoInit
public struct ExampleStruct {
    public let name: String
    public let age: Int?
    public let onComplete: () -> Void
    public let optionalClosure: (() -> String)?
    public let optionalClosureResult: () -> String?
    public static var test: String {
        ""
    }
}

// MARK: - DAO+Example

import SDAO
import RealmSwift

// MARK: - MainPlainObject

@DAOMacro
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

// MARK: - Enums

public enum StringEnum: String, Codable {
    case case1
    case case2
}

public enum IntEnum: Int, Codable {
    case case1
    case case2
}
