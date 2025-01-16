import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwiftMacrosKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DynamicStringWrapperMacro.self,
        WithLocalizationUpdaterMacro.self,
        ClosureAccessorMacro.self,
        AutoInitMacro.self,
        DAOPlainMacro.self
    ]
}
