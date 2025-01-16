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
        if property.isShouldUseRealmProperty {
            return "let \(property.name) = RealmProperty<\(property.realmSupportedType)?>()"
        } else {
            return "@objc dynamic var \(property.name): \(property.realmSupportedType)? = nil"
        }
    }
}
