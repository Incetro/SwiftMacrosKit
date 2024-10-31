//
//  AutoInitMacro.swift
//
//
//  Created by Gleb Kovalenko on 31.10.2024.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - AutoInitMacro

/// A macro that generates a public initializer for a struct, handling different types of properties.
/// - Adds `@escaping` for non-optional closures.
/// - Provides default values for optional closures and optional properties.
public struct AutoInitMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        /// Ensure the macro is applied to a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError(message: "Macro can only be applied to a struct.")
        }

        /// Collect properties of the struct
        let properties = structDecl.memberBlock.members.compactMap { member -> (name: String, type: String, isClosure: Bool, returnsOptional: Bool, isOptional: Bool)? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let binding = variable.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation else {
                return nil
            }
            
            let type = typeAnnotation.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            let isClosure = type.hasPrefix("(") && type.contains("->")
            let returnsOptional = isClosure && type.contains("->") && type.hasSuffix("?")
            let isOptional = isClosure ? type.hasSuffix(")?") : type.hasSuffix("?")
            
            return (name: identifier.identifier.text, type: type, isClosure: isClosure, returnsOptional: returnsOptional, isOptional: isOptional)
        }

        /// Build initializer parameters and assignments
        var initializerParams: [String] = []
        var initializerAssignments: [String] = []

        for property in properties {
            if property.isClosure {
                /// Handle closures
                if property.isOptional {
                    initializerParams.append("\(property.name): \(property.type) = nil")
                } else if property.returnsOptional {
                    initializerParams.append("\(property.name): @escaping \(property.type) = { nil }")
                } else {
                    initializerParams.append("\(property.name): @escaping \(property.type)")
                }
            } else if property.isOptional {
                /// Handle optional properties
                initializerParams.append("\(property.name): \(property.type) = nil")
            } else {
                /// Handle non-optional properties
                initializerParams.append("\(property.name): \(property.type)")
            }
            initializerAssignments.append("self.\(property.name) = \(property.name)")
        }

        /// Create the initializer
        let initializer = """
        public init(
            \(initializerParams.joined(separator: ",\n    "))
        ) {
            \(initializerAssignments.joined(separator: "\n    "))
        }
        """

        return [DeclSyntax(stringLiteral: initializer)]
    }
}


