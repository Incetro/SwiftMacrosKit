import SwiftMacrosKit
import SwiftUI

// MARK: - DynamicStringWrapper+Example

@DynamicStringWrapper
public struct SomeStruct {
    public var optionalString: String?
    public var string: String
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
