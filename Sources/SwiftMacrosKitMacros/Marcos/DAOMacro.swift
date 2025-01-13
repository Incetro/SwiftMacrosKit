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
    
    public enum ModelType: String {
        
        // MARK: - Cases
        
        case primitive
        case stringEnum
        case intEnum
        case plain
    }
    
    // MARK: - PropertyPlain
    
    public struct PropertyPlain {
        
        // MARK: - Properties
        
        public let name: String
        public let type: String
        public let modelType: ModelType
        public let isArray: Bool
        public let isOptional: Bool
        
    }
    
    // MARK: - Properties
    
    private static let numericTypes = [
        "Int", "Int8", "Int16", "Int32", "Int64",
        "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
        "Float", "Double", "Float80"
    ]
    
    private static let stringTypes = [
        "String", "URL"
    ]
    
    private static let annotations: [String: ModelType] = [
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
        let properties = extractPropeties(members: structDecl.memberBlock.members)
        let modelClass = makeModel(properties: properties)
        return [
            modelClass
        ]
    }
}

// MARK: - Extension Macro

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

// MARK: - Private

extension DAOMacro {
    
    private static func makeModel(properties: [PropertyPlain]) -> DeclSyntax {
        var realmProperties: [String] = []
        
        for property in properties {
            switch property.isArray {
            case true:
                realmProperties.append("let \(property.name) = RealmSwift.List<\(property.type)>()")
            case false:
                let propertyDeclaration: String
                switch property.isOptional {
                case true:
                    propertyDeclaration = makeOptionalObjcType(
                        name: property.name,
                        type: property.type,
                        modelType: property.modelType
                    )
                case false:
                    let defaultValue: String?
                    switch property.type {
                    case _ where numericTypes.contains(property.type):
                        defaultValue = "0"
                    case _ where stringTypes.contains(property.type):
                        defaultValue = "\"\""
                    case "Date":
                        defaultValue = "Date()"
                    default:
                        defaultValue = nil
                    }
                    if let defaultValue {
                        propertyDeclaration = "@objc dynamic var \(property.name): \(property.type) = \(defaultValue)"
                    } else {
                        propertyDeclaration = makeOptionalObjcType(
                            name: property.name,
                            type: property.type,
                            modelType: property.modelType
                        )
                    }
                }
                realmProperties.append(propertyDeclaration)
            }
        }
        
        let modelClass = """
        public final class Model: RealmModel {
            
            // MARK: - Properties
        
            \(realmProperties.joined(separator: "\n    "))
        }
        """
        return DeclSyntax(stringLiteral: modelClass)
    }
    
    private static func extractPropeties(members: MemberBlockItemListSyntax) -> [PropertyPlain] {
        members.compactMap { member -> PropertyPlain? in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  let binding = variable.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation else {
                return nil
            }
            
            for modifier in variable.modifiers {
                if modifier.as(DeclModifierSyntax.self)?.name.text == "static" {
                    return nil
                }
            }
            
            let name = identifier.identifier.text
            var type = typeAnnotation.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            guard type != "UniqueID" else {
                return nil
            }
            let isArray = type.hasPrefix("[") && (type.hasSuffix("]") || type.hasSuffix("]?"))
            let isOptional = type.hasSuffix("?")
            let docComment = variable.leadingTrivia
                .compactMap ({ piece in
                    switch piece {
                    case let .docLineComment(comment): return comment
                    default: return nil
                    }
                })
                .joined(separator: " ")
            let modelType = annotations.first { docComment.contains($0.key) }?.value ?? .primitive
            type = detectType(isArray: isArray, type: type, modelType: modelType)
            return PropertyPlain(
                name: name,
                type: type,
                modelType: modelType,
                isArray: isArray,
                isOptional: isOptional
            )
        }
    }
    
    private static func detectType(isArray: Bool, type: String, modelType: ModelType) -> String {
        let initialType = isArray
        ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]?"))
        : type.trimmingCharacters(in: CharacterSet(charactersIn: "?"))
        switch modelType {
        case .stringEnum, .intEnum:
            return "\(initialType).RawValue"
        case .plain:
            return "\(initialType).Model"
        case .primitive where stringTypes.contains(initialType):
            return "String"
        case .primitive:
            return initialType
        }
    }
    
    private static func makeOptionalObjcType(name: String, type: String, modelType: ModelType) -> String {
        if numericTypes.contains(type) || modelType == .intEnum {
            return "let \(name) = RealmProperty<\(type)?>()"
        } else {
            return "@objc dynamic var \(name): \(type)? = nil"
        }
    }
}
