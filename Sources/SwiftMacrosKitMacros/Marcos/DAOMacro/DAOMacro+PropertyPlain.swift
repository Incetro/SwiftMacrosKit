//
//  DAOPlainMacro+PropertyPlain.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOPlainMacro+PropertyPlain

/// `PropertyPlain` defines the structure of a property in the plain object model.
/// It contains metadata about the property, such as its type, whether it's an array,
/// optional, or an enum, and whether it needs special handling for Realm.
///
/// This struct is used to generate the corresponding database model and translator logic.
extension DAOPlainMacro {
    
    struct PropertyPlain {
        
        // MARK: - Properties
        
        /// The name of the plain object.
        let plainName: String
        
        /// Model name
        let modelName: String
        
        /// The property name in the plain model.
        let name: String
        
        /// Indicates is property computed
        let isComputed: Bool
        
        /// The type of the property after adapting to Realm-compatible types.
        let realmSupportedType: String
        
        /// The initial type as defined in the plain model.
        let initialType: String
        
        /// The type of the property (primitive, enum, or plain object).
        let modelType: ModelType
        
        /// Indicates whether the property is an array.
        let isArray: Bool
        
        /// Indicates whether the property is optional.
        let isOptional: Bool
    }
}

// MARK: - Computed

extension DAOPlainMacro.PropertyPlain {
    
    /// Determines if the property requires `RealmProperty` wrapping.
    var isShouldUseRealmProperty: Bool {
        DAOPlainMacro.typesSupportedRealmProperty.contains(initialType) || (modelType == .intEnum && !isArray)
    }
    
    /// Provides a default value for the property based on its type.
    var realmSupportedDefaultValue: String? {
        switch realmSupportedType {
        case _ where DAOPlainMacro.numericTypes.contains(realmSupportedType):
            return "0"
        case _ where DAOPlainMacro.stringTypes.contains(realmSupportedType):
            return "\"\""
        case "Date":
            return "Date()"
        default:
            return nil
        }
    }
    
    /// Checks if the property is an enum type.
    var isEnumType: Bool {
        switch modelType {
        case .intEnum, .stringEnum:
            return true
        default:
            return false
        }
    }
    
    /// Determines if the property requires a default value when translating from a model.
    var isShouldUseDefaultValueWhileTranslateFromModel: Bool {
        (isShouldUseRealmProperty || isEnumType || initialType == "URL?") && !isArray
    }
    
    /// Determines if the property needs to be unwrapped during translation from a model.
    var isShouldUnwrapWhileTranslateFromModel: Bool {
        (isEnumType || initialType == "URL") && !isArray
    }
    
    /// Provides the type name without array or optional modifiers.
    var clearTypeName: String {
        initialType
            .trimmingCharacters(in: CharacterSet(charactersIn: "[]?"))
            .trimmingCharacters(in: CharacterSet(charactersIn: "?"))
    }
    
    /// Provides a default value for the property.
    var defaultValue: String {
        guard !isArray else {
            return "[]"
        }
        switch self.modelType {
        case .intEnum:
            return "0"
        case .stringEnum:
            return "\"\""
        case .plain:
            return ""
        case .primitive:
            return realmSupportedDefaultValue ?? ""
        }
    }
}

// MARK: - MacrosStrings

extension DAOPlainMacro.PropertyPlain {
    
    var defaultValueUnwrapString: String {
        guard isShouldUseDefaultValueWhileTranslateFromModel else {
            return ""
        }
        return " ?? \(defaultValue)"
    }
    
    var unsafelyUnwrappedString: String {
        guard isShouldUnwrapWhileTranslateFromModel else {
            return ""
        }
        return ".unsafelyUnwrapped"
    }
}

// MARK: - Usesful

extension DAOPlainMacro.PropertyPlain {
    
    /// Returns the initialization string for translation based on the translation type.
    /// - Parameters:
    ///   - translateType: The type of translation (`fromModelToPlain` or `fromPlainToModel`).
    /// - Returns: A closure that generates the initialization string for translation.
    func initString(for translateType: DAOPlainMacro.TranslateType) -> ((String) -> String)? {
        switch self.modelType {
        case .stringEnum, .intEnum:
            switch translateType {
            case .fromModelToPlain:
                return { value in
                    "\(clearTypeName)(rawValue: \(value)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                }
            case .fromPlainToModel:
                return { value in
                    "\(value).rawValue"
                }
            }
        case .primitive where clearTypeName == "URL":
            switch translateType {
            case .fromModelToPlain:
                return { value in
                    "\(clearTypeName)(string: \(value)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                }
            case .fromPlainToModel:
                return { value in
                    "\(value).absoluteString"
                }
            }
        default:
            return nil
        }
    }
    
    /// Generates the translation string for the property based on the translation type and value path.
    /// - Parameters:
    ///   - translateType: The type of translation (`fromModelToPlain` or `fromPlainToModel`).
    ///   - valuePath: The value path to be translated.
    /// - Returns: A string representing the translation logic.
    func translate(with translateType: DAOPlainMacro.TranslateType, valuePath: String) -> String? {
        guard translateType != .fromModelToPlain || !isComputed else {
            return nil
        }
        switch modelType {
        case .stringEnum, .intEnum,
             .primitive where clearTypeName == "URL":
            let optionalSuffix = translateType == .fromPlainToModel && isOptional ? "?" : ""
            let arrayUnwrapString = translateType == .fromPlainToModel && isOptional ? " ?? []" : ""
            guard let initString = initString(for: translateType) else {
                return ""
            }
            return isArray ? "\(valuePath)\(optionalSuffix).compactMap({ \(initString("$0")) })\(arrayUnwrapString)" : initString(valuePath + optionalSuffix)
        case .primitive:
            let defaultValueUnwrapString = translateType == .fromModelToPlain ? self.defaultValueUnwrapString : ""
            let shouldBeConvertToArray = translateType == .fromModelToPlain && isArray
            return (shouldBeConvertToArray ? "Array(" : "") + "\(valuePath)\(defaultValueUnwrapString)" + (shouldBeConvertToArray ? ")" : "")
        case .plain:
            let translatorInitString = "Translator(configuration: configuration)"
            switch translateType {
            case .fromModelToPlain:
                let checkNilString = isArray ? "" : "\(valuePath) == nil ? nil :"
                let translateString = "translate(\(isArray ? "models: Array(\(valuePath))" : "model: \(valuePath).unsafelyUnwrapped"))"
                return (isOptional ? checkNilString : "") + "try \(clearTypeName).\(translatorInitString).\(translateString)"
            case .fromPlainToModel:
                let checkNilString = "\(valuePath) == nil ? \(isArray ? "[]" : "nil") : "
                let optionalUnwrapString = isOptional ? ".unsafelyUnwrapped" : ""
                let translateString = "translate(\(isArray ? "plains: \(valuePath)\(optionalUnwrapString)" : "plain: \(valuePath)\(optionalUnwrapString)"))"
                return (isOptional ? checkNilString : "") + "try \(clearTypeName).\(translatorInitString).\(translateString)"
            }
        }
    }
}
