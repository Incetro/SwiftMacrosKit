import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftMacrosKitMacros)
import SwiftMacrosKitMacros

let testMacros: [String: Macro.Type] = [
    "AutoInit": AutoInitMacro.self,
]
#endif


final class SwiftMacrosKitTests: XCTestCase {
    func testMacro() throws {
        #if canImport(SwiftMacrosKitMacros)
        assertMacroExpansion(
            """
            @AutoInit
            public struct ExampleStruct {
                public let name: String
                public let age: Int?
                public let onComplete: () -> Void
                public let optionalClosure: (() -> String)?
                public let optionalClosureResult: () -> String?
            }
            """,
            expandedSource: """
            privet
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
