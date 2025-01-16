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
    
    // MARK: - TranslateType
    
    enum TranslateType {

        // MARK: - Cases
        
        case fromModelToPlain
        case fromPlainToModel
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
            "extension \(type.trimmed): SDAO.Plain {}"
        )
        return [equatableExtension]
    }
}

// MARK: - Useful

extension DAOMacro {
    
    static func extractPropeties(plainName: String, members: MemberBlockItemListSyntax) -> [PropertyPlain] {
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
