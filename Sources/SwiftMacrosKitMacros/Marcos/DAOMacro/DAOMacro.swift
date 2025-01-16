//
//  DAOPlainMacro.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 10.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOPlainMacro

/// A structure representing the core logic for generating data access object (DAO) components.
///
/// The `DAOPlainMacro` contains metadata, configurations, and utilities for generating
/// Realm-compatible database models and translators from annotated plain object structures.
/// It defines types, annotations, and utility functions used throughout the macro's implementation.
public struct DAOPlainMacro {
    
    // MARK: - ModelType
    
    /// Represents the type of a property within a plain object.
    ///
    /// This is determined based on annotations or the property's inferred type.
    enum ModelType {
        
        // MARK: - Cases
        
        /// A property that is an enumerated type with a `String` raw value.
        case stringEnum
        
        /// A property that is an enumerated type with an `Int` raw value.
        case intEnum
        
        /// A property that is another plain object type.
        case plain
        
        /// A primitive property (e.g., `String`, `Int`, etc.).
        case primitive
    }
    
    // MARK: - TranslateType
    
    /// Represents the direction of translation between plain objects and database models.
    enum TranslateType {

        // MARK: - Cases
        
        /// Translation from the database model to the plain object.
        case fromModelToPlain
        
        /// Translation from the plain object to the database model.
        case fromPlainToModel
    }
    
    // MARK: - Properties
    
    /// A list of numeric types supported by the macro.
    ///
    /// These types can be wrapped in `RealmProperty` for optionality support.
    static let numericTypes = [
        "Int", "Int8", "Int16", "Int32", "Int64",
        "Float", "Double"
    ]
    
    /// A list of types supported by `RealmProperty`.
    ///
    /// Includes optional numeric types and other Realm-compatible types.
    static var typesSupportedRealmProperty = numericTypes.map { "\($0)?" } + [
        "Bool?"
    ]
    
    /// A list of string-like types supported by the macro.
    ///
    /// These types are often mapped to `String` in the database model.
    static let stringTypes = [
        "String", "URL"
    ]
    
    /// A mapping of annotations to `ModelType` values.
    ///
    /// Annotations are used in documentation comments to explicitly define a property's type
    /// (e.g., plain, integer enum, string enum).
    static let annotations: [String: ModelType] = [
        "@dao-string-enum": .stringEnum,
        "@dao-int-enum": .intEnum,
        "@dao-plain": .plain
    ]
}

// MARK: - MemberMacro

extension DAOPlainMacro: MemberMacro {
    
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError(message: "@DAO can only be applied to a struct.")
        }
        let properties = extractPropeties(
            plainName: structDecl.name.text,
            members: structDecl.memberBlock.members
        )
        let modelClass = makeModel(properties: properties)
        let translatorClass = makeTranslator(plainName: structDecl.name.text, properties: properties)
        let daoAlias = makeDAOAlias(plainName: structDecl.name.text)
        return [
            daoAlias,
            modelClass,
            translatorClass
        ]
    }
}

// MARK: - ExtensionMacro

extension DAOPlainMacro: ExtensionMacro {
    
    /// Expands the macro to add `Identifiable, Plain` conformance to the struct.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let equatableExtension = try ExtensionDeclSyntax(
            "extension \(type.trimmed): SDAO.Plain {}"
        )
        return [equatableExtension]
    }
}

// MARK: - Useful

extension DAOPlainMacro {
    
    /// Extracts the properties of a plain object for further processing.
    ///
    /// This method parses the members of a struct declaration to identify
    /// its properties, extracting metadata such as:
    /// - Name, type, and whether it is optional or an array.
    /// - Model type based on annotations (e.g., `@dao-plain`, `@dao-int-enum`).
    /// - Realm-compatible type for database model generation.
    ///
    /// This method also filters out unsupported members, such as static variables,
    /// computed properties, methods, and specific excluded types like `UniqueID`.
    ///
    /// - Parameters:
    ///   - plainName: The name of the plain object (used for nested type references).
    ///   - members: The list of members in the struct declaration.
    /// - Returns: An array of `PropertyPlain` objects representing the extracted properties.
    static func extractPropeties(plainName: String, members: MemberBlockItemListSyntax) -> [PropertyPlain] {
        members.compactMap { member -> PropertyPlain? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let binding = variable.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation,
                  binding.accessorBlock == nil else {
                return nil
            }
            
            for modifier in variable.modifiers {
                if modifier.as(DeclModifierSyntax.self)?.name.text == "static" {
                    return nil
                }
            }
            
            let name = identifier.identifier.text
            let initialType = typeAnnotation.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            guard initialType != "UniqueID" else {
                return nil
            }
            let isArray = initialType.hasPrefix("[") && (initialType.hasSuffix("]") || initialType.hasSuffix("]?"))
            let isOptional = initialType.hasSuffix("?")
            let docComment = variable.leadingTrivia
                .compactMap ({ piece in
                    switch piece {
                    case let .docLineComment(comment): return comment
                    default: return nil
                    }
                })
                .joined(separator: " ")
            let modelType = annotations.first { docComment.contains($0.key) }?.value ?? .primitive
            let realmSupportedType = detectRealmSupportedType(
                isArray: isArray,
                initialType: initialType,
                modelType: modelType
            )
            let plain = PropertyPlain(
                plainName: plainName,
                name: name,
                realmSupportedType: realmSupportedType,
                initialType: initialType,
                modelType: modelType,
                isArray: isArray,
                isOptional: isOptional
            )
            return plain
        }
    }
}
