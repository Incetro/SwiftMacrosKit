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
        "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
        "Float", "Double", "Float80"
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
        return [
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
        if !property.isOptional && property.isOptionalInDatabaseModel {
            return "\(property.name): \(property.name)"
        }
        switch property.isArray {
        case true:
            switch property.modelType {
            case .stringEnum, .intEnum:
                return "\(property.name): \(modelValuePath).compactMap({ \(property.typeName)(rawValue: $0) })"
            case .primitive:
                switch property.typeName {
                case "URL":
                return "\(property.name): \(modelValuePath).compactMap({ \(property.typeName)(string: $0) })"
                default:
                    return "\(property.name): \(modelValuePath)"
                }
            case .plain:
                return "\(property.name): try \(property.plainName).Translator(configuration: configuration).translate(models: Array(\(modelValuePath)\(property.optionalUnwrapString))"
            }
        case false:
            switch property.modelType {
            case .stringEnum, .intEnum:
                return "\(property.name): \(property.typeName)(rawValue: \(modelValuePath)\(property.optionalUnwrapString))"
            case .primitive:
                switch property.typeName {
                case "URL":
                    return "\(property.name): URL(string: \(modelValuePath)\(property.optionalUnwrapString))"
                default:
                    return "\(property.name): \(modelValuePath)\(property.optionalUnwrapString)"
                }
            case .plain:
                if property.isOptional {
                    return "\(property.name): \(modelValuePath) == nil ? nil : try \(property.plainName).Translator(configuration: configuration).translate(model: \(modelValuePath).unsafelyUnwrapped)"
                }
                return "\(property.name): try \(property.plainName).Translator(configuration: configuration).translate(model: \(modelValuePath)"
            }
        }
    }
}
