import SwiftMacrosKit
import SwiftUI

// MARK: - DynamicStringWrapper+Example

@DynamicStringWrapper
public struct SomeStruct {
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

@DAOMacro
public struct ShortBankAccountPlainObject: Equatable, Codable {
    
    // MARK: - Properties
    
    /// Account name
    public let account: String?
    
    /// Account balance
    public let balance: Double
    
    /// Acount image url
    public let imageURL: URL?
}
