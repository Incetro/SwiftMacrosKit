//
//  DAOMacro+DatabaseModelGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro+DatabaseModelGeneration

extension DAOMacro {
    
    static func makeModel(properties: [PropertyPlain]) -> DeclSyntax {
        var realmProperties: [String] = []
        
        for property in properties {
            switch property.isArray {
            case true:
                realmProperties.append("let \(property.name) = RealmSwift.List<\(property.realmSupportedType)>()")
            case false:
                let propertyDeclaration: String
                switch property.isOptional {
                case true:
                    propertyDeclaration = makeOptionalObjcType(property: property)
                case false:
                    if let defaultValue = property.realmSupportedDefaultValue {
                        propertyDeclaration = "@objc dynamic var \(property.name): \(property.realmSupportedType) = \(defaultValue)"
                    } else {
                        propertyDeclaration = makeOptionalObjcType(property: property)
                    }
                }
                realmProperties.append(propertyDeclaration)
            }
        }
        
        let modelClass = """
        public final class DatabaseModel: RealmModel {
            
            // MARK: - Properties
        
            \(realmProperties.joined(separator: "\n    "))
        }
        """
        return DeclSyntax(stringLiteral: modelClass)
    }
    
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
            return PropertyPlain(
                plainName: plainName,
                name: name,
                realmSupportedType: realmSupportedType,
                initialType: initialType,
                modelType: modelType,
                isArray: isArray,
                isOptional: isOptional
            )
        }
    }
    
    static func detectRealmSupportedType(isArray: Bool, initialType: String, modelType: ModelType) -> String {
        let initialType = isArray
        ? initialType.trimmingCharacters(in: CharacterSet(charactersIn: "[]?"))
        : initialType.trimmingCharacters(in: CharacterSet(charactersIn: "?"))
        switch modelType {
        case .stringEnum, .intEnum:
            return "\(initialType).RawValue"
        case .plain:
            return "\(initialType).DatabaseModel"
        case .primitive where stringTypes.contains(initialType):
            return "String"
        case .primitive:
            return initialType
        }
    }
    
    static func makeOptionalObjcType(property: PropertyPlain) -> String {
        if property.shouldUseRealmProperty {
            return "let \(property.name) = RealmProperty<\(property.realmSupportedType)?>()"
        } else {
            return "@objc dynamic var \(property.name): \(property.realmSupportedType)? = nil"
        }
    }
}
