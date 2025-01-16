//
//  File.swift
//  
//
//  Created by Gleb Kovalenko on 30.10.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - ClosureAccessorMacro

/// The `ClosureAccessorMacro` automatically generates a `get` accessor for properties,
/// using a closure as the backing store for the property value.
/// This allows the value to be dynamically evaluated, which is useful for lazy loading or localization scenarios.
public struct ClosureAccessorMacro: AccessorMacro {

    // MARK: - Expansion Method

    /// Expands the macro to generate a `get` accessor that retrieves values from a backing closure.
    ///
    /// - Parameters:
    ///   - node: The `AttributeSyntax` node where the macro is applied.
    ///   - declaration: The `DeclSyntaxProtocol` to which the macro is attached.
    ///   - context: The context in which the macro expansion occurs.
    ///
    /// - Returns: An array of `AccessorDeclSyntax` containing the generated `get` accessor.
    /// - Throws: `MacroError` if the macro is not applied to a variable property.
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {

        // Ensure the declaration is a `var` property
        guard let variableDecl = declaration.as(VariableDeclSyntax.self),
              let binding = variableDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw MacroError(message: "Macro can only be applied to variable properties.")
        }

        let propertyName = identifier.identifier.text
        let closureName = "\(propertyName)Closure"

        let accessorCode = "\(closureName)()"

        // Generate the `get` accessor that retrieves the value using the closure
        let getter = """
        get {
            \(accessorCode)
        }
        """

        return [AccessorDeclSyntax(stringLiteral: getter)]
    }
}

