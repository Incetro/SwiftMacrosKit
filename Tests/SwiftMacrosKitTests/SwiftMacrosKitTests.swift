import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftMacrosKitMacros)
import SwiftMacrosKitMacros

let testMacros: [String: Macro.Type] = [
    "DAOPlain": DAOPlainMacro.self,
]
#endif


final class SwiftMacrosKitTests: XCTestCase {
    func testMacro() throws {
        #if canImport(SwiftMacrosKitMacros)
        assertMacroExpansion(
            """
            @DAOPlain
            public struct MainPlainObject: Equatable, Codable {
                
                public var uniqueId: UniqueID {
                    UniqueID(rawValue: id)
                }
                
                public static let staticVariable = "staticVariable"
            
                public var someComputedProperty: Int {
                    int
                }
                
                /// @dao-ignore
                public var ignoredComputedProperty: Int {
                    0
                }
            
                /// @dao-int-enum
                public var complexComptuedIntEnum: IntEnum {
                    switch stringEnum {
                    case .case1:
                        return .case1
                    case .case2:
                        return .case2
                    }
                }
                
                /// @dao-string-enum
                public var complexComptuedStringEnum: StringEnum {
                    switch intEnum {
                    case .case1:
                        return .case1
                    case .case2:
                        return .case2
                    }
                }
                
                public var complexComputedInt: Int {
                    switch stringEnum {
                    case .case1:
                        return 0
                    case .case2:
                        return 1
                    }
                }
                
                public var complexComputedString: String {
                    switch stringEnum {
                    case .case1:
                        return ""
                    case .case2:
                        return ""
                    }
                }
                
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
            """,
            expandedSource: """
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif

    }

    func testMacroWithStringLiteral() throws {
    }
}
