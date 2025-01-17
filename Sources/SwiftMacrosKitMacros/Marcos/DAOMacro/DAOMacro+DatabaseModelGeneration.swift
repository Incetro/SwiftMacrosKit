//
//  DAOPlainMacro+DatabaseModelGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOPlainMacro+DatabaseModelGeneration

extension DAOPlainMacro {
    
    /// Generates the `DatabaseModel` class for the plain object.
    ///
    /// This method constructs a Realm-compatible model class by iterating
    /// over the properties of the plain object and creating appropriate
    /// declarations for each property. It handles:
    /// - Arrays with `RealmSwift.List`.
    /// - Optionals with `RealmProperty` or `@objc dynamic`.
    /// - Default values for primitives and strings.
    ///
    /// - Parameters:
    ///   - properties: An array of `PropertyPlain` representing the properties
    ///                 of the plain object.
    /// - Returns: A `DeclSyntax` object representing the generated `DatabaseModel` class.
    static func makeModel(properties: [PropertyPlain], plainName: String) -> DeclSyntax {
        var realmProperties: [String] = []
        
        for property in properties {
            switch property.isArray {
            case true:
                realmProperties.append("let \(property.modelName) = RealmSwift.List<\(property.realmSupportedType)>()")
            case false:
                let propertyDeclaration: String
                switch property.isOptional {
                case true:
                    propertyDeclaration = makeOptionalObjcType(property: property)
                case false:
                    if let defaultValue = property.realmSupportedDefaultValue {
                        propertyDeclaration = "@objc dynamic var \(property.modelName): \(property.realmSupportedType) = \(defaultValue)"
                    } else {
                        propertyDeclaration = makeOptionalObjcType(property: property)
                    }
                }
                realmProperties.append(propertyDeclaration)
            }
        }
        
        let modelClass = """
        
        // MARK: - DatabaseModel
        
        @objc(\(plainName)DatabaseModel)
        public final class DatabaseModel: RealmModel {
            
            // MARK: - Properties
        
            \(realmProperties.joined(separator: "\n    "))
        }
        """
        return DeclSyntax(stringLiteral: modelClass)
    }
    
    /// Detects the type supported by Realm for a given property.
    ///
    /// Depending on the property type and model type, this method determines
    /// how to represent the property in the Realm model. For example:
    /// - Enums are represented by their raw value.
    /// - Plain objects are represented by their `DatabaseModel`.
    /// - Strings and URLs are converted to `String`.
    ///
    /// - Parameters:
    ///   - isArray: Indicates whether the property is an array.
    ///   - initialType: The original type of the property.
    ///   - modelType: The model type of the property (e.g., plain, enum, or primitive).
    /// - Returns: The detected Realm-supported type as a string.
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
    
    /// Generates the declaration for an optional property in a Realm model.
    ///
    /// This method determines whether the property should use a `RealmProperty` wrapper
    /// or a standard Objective-C dynamic property.
    ///
    /// - Parameter property: The property for which the declaration is being generated.
    /// - Returns: A string representing the property declaration.
    static func makeOptionalObjcType(property: PropertyPlain) -> String {
        if property.isShouldUseRealmProperty {
            return "let \(property.modelName) = RealmProperty<\(property.realmSupportedType)?>()"
        } else {
            return "@objc dynamic var \(property.modelName): \(property.realmSupportedType)? = nil"
        }
    }
}
