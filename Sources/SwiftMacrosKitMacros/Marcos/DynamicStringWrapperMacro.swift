//
//  DynamicStringWrapperMacro.swift
//
//
//  Created by Gleb Kovalenko on 30.10.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - DynamicStringWrapperMacro

/// The `DynamicStringWrapperMacro` generates closures for each `String` and `String?` property
/// in a struct, creating a flexible way to dynamically update or localize string values.
/// It also includes an initializer to set these closures, adds a conformance to `Equatable`,
/// and attaches a `@ClosureAccessor` attribute to each relevant property.
public struct DynamicStringWrapperMacro: MemberMacro {

    // MARK: - Expansion Method for Member Macro

    /// Expands the macro to create closures for each `String` property, an initializer, and an `Equatable` method.
    ///
    /// - Parameters:
    ///   - attribute: The `AttributeSyntax` node where the macro is applied.
    ///   - declaration: The `DeclGroupSyntax` for which the macro is attached.
    ///   - context: The context in which the macro expansion occurs.
    ///
    /// - Returns: An array of `DeclSyntax` containing closures, an initializer, and an `Equatable` implementation.
    /// - Throws: `MacroError` if the macro is not applied to a struct.
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        /// Ensure the macro is applied to a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError(message: "Macro can only be applied to a struct.")
        }
        
        /// Collects properties that are `var` and are `String` or `String?`
        let properties = structDecl.memberBlock.members.compactMap { member -> (name: String, isOptional: Bool)? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let binding = variable.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                return nil
            }
            
            let isOptional = binding.typeAnnotation?.type.description.contains("?") ?? false
            return (name: identifier.identifier.text, isOptional: isOptional)
        }
        
        /// Arrays to hold generated closures, initializer parameters, assignments, and Equatable comparisons
        var closureDeclarations: [DeclSyntax] = []
        var initializerParams: [String] = []
        var initializerAssignments: [String] = []
        var equatableComparisons: [String] = []
        
        /// Generate closures, initializer parameters, and Equatable comparisons
        for property in properties {
            let closureName = "\(property.name)Closure"
            let closureDeclaration = """
            private let \(closureName): \(property.isOptional ? "() -> String?" : "() -> String")
            """
            
            closureDeclarations.append(DeclSyntax(stringLiteral: closureDeclaration))
            
            let paramType = property.isOptional
                ? "@autoclosure @escaping () -> String? = { nil }()"
                : "@autoclosure @escaping () -> String"
            initializerParams.append("\(property.name): \(paramType)")
            initializerAssignments.append("self.\(closureName) = \(property.name)")
            
            equatableComparisons.append("lhs.\(property.name) == rhs.\(property.name)")
        }
        
        /// Create the initializer with parameters and assignments
        let initializer = """
        public init(
            \(initializerParams.joined(separator: ",\n    "))
        ) {
            \(initializerAssignments.joined(separator: "\n    "))
        }
        """
        
        /// Create the `Equatable` method
        let equatableMethod = """
        public static func == (lhs: \(structDecl.name.text), rhs: \(structDecl.name.text)) -> Bool {
            return \(equatableComparisons.joined(separator: " && "))
        }
        """
        
        return closureDeclarations +
               [DeclSyntax(stringLiteral: initializer),
                DeclSyntax(stringLiteral: equatableMethod)]
    }
}

// MARK: - MemberAttribute Macro

extension DynamicStringWrapperMacro: MemberAttributeMacro {
    
    /// Adds the `@ClosureAccessor` attribute to each property for dynamic access.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        let closureAccessorAttribute = AttributeSyntax(
            attributeName: TypeSyntax(stringLiteral: "ClosureAccessor")
        )
        return [closureAccessorAttribute]
    }
}

// MARK: - Extension Macro

extension DynamicStringWrapperMacro: ExtensionMacro {
    
    /// Expands the macro to add `Equatable` conformance to the struct.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let equatableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Equatable {}")
        return [equatableExtension]
    }
}

