//
//  DAOMacro.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 10.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro

public struct DAOMacro {
    
    // MARK: - ModelType
    
    enum ModelType {
        
        // MARK: - Cases
        
        case stringEnum
        case intEnum
        case plain
        case primitive
    }
    
    // MARK: - Properties
    
    static let numericTypes = [
        "Int", "Int8", "Int16", "Int32", "Int64",
        "Float", "Double"
    ]
    
    static var typesSupportedRealmProperty = numericTypes.map { "\($0)?" } + [
        "Bool?"
    ]
    
    static let stringTypes = [
        "String", "URL"
    ]
    
    static let annotations: [String: ModelType] = [
        "@dao-string-enum": .stringEnum,
        "@dao-int-enum": .intEnum,
        "@dao-plain": .plain
    ]
}

// MARK: - MemberMacro

extension DAOMacro: MemberMacro {
    
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

extension DAOMacro: ExtensionMacro {
    
    /// Expands the macro to add `Identifiable, Plain` conformance to the struct.
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let equatableExtension = try ExtensionDeclSyntax(
            "extension \(type.trimmed): Identifiable, Plain {}"
        )
        return [equatableExtension]
    }
}

// MARK: - Useful

extension DAOMacro {
    
    static func makeInitVariableString(
        modelValuePath: String,
        property: PropertyPlain
    ) -> String {
        switch property.isArray {
        case true:
            switch property.modelType {
            case .stringEnum, .intEnum:
                return "\(property.name): \(modelValuePath).compactMap({ \(property.clearTypeName)(rawValue: $0) })"
            case .primitive:
                switch property.clearTypeName {
                case "URL":
                return "\(property.name): \(modelValuePath).compactMap({ \(property.clearTypeName)(string: $0) })"
                default:
                    return "\(property.name): \(modelValuePath)"
                }
            case .plain:
                return "\(property.name): try \(property.clearTypeName).Translator(configuration: configuration).translate(models: Array(\(modelValuePath)\(property.defaultValueUnwrapString)))"
            }
        case false:
            switch property.modelType {
            case .stringEnum, .intEnum:
                return "\(property.name): \(property.clearTypeName)(rawValue: \(modelValuePath)\(property.defaultValueUnwrapString))\(property.unsafelyUnwrappedString)"
            case .primitive:
                switch property.clearTypeName {
                case "URL":
                    return "\(property.name): URL(string: \(modelValuePath)\(property.defaultValueUnwrapString))\(property.unsafelyUnwrappedString)"
                default:
                    return "\(property.name): \(modelValuePath)\(property.defaultValueUnwrapString)"
                }
            case .plain:
                if property.isOptional {
                    return "\(property.name): \(modelValuePath) == nil ? nil : try \(property.clearTypeName).Translator(configuration: configuration).translate(model: \(modelValuePath).unsafelyUnwrapped)"
                }
                return "\(property.name): try \(property.clearTypeName).Translator(configuration: configuration).translate(model: \(modelValuePath).unsafelyUnwrapped)"
            }
        }
    }
}
