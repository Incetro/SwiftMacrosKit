//
//  DAOMacro+PropertyPlain.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro+PropertyPlain

extension DAOMacro {
    
    // MARK: - PropertyPlain
    
    struct PropertyPlain {
        
        // MARK: - Properties
        
        let plainName: String
        let name: String
        let realmSupportedType: String
        let initialType: String
        let modelType: ModelType
        let isArray: Bool
        let isOptional: Bool
        
        // MARK: - Useful
        
        var isShouldUseRealmProperty: Bool {
            typesSupportedRealmProperty.contains(initialType) || (modelType == .intEnum && !isArray)
        }
        
        var realmSupportedDefaultValue: String? {
            switch realmSupportedType {
            case _ where numericTypes.contains(realmSupportedType):
                return "0"
            case _ where stringTypes.contains(realmSupportedType):
                return "\"\""
            case "Date":
                return "Date()"
            default:
                return nil
            }
        }
        
        var isEnumType: Bool {
            switch modelType {
            case .intEnum, .stringEnum:
                return true
            default:
                return false
            }
        }
        
        var isShouldUseDefaultValueWhileTranlateFromModel: Bool {
            (isShouldUseRealmProperty || isEnumType || initialType == "URL?") && !isArray
        }
        
        var isShouldUnwrapWhileTranlateFromModel: Bool {
            (isEnumType || initialType == "URL") && !isArray
        }
        
        var clearTypeName: String {
            initialType
                .trimmingCharacters(in: CharacterSet(charactersIn: "[]?"))
                .trimmingCharacters(in: CharacterSet(charactersIn: "?"))
        }
        
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
        
        // MARK: - MacrosStrings
        
        var defaultValueUnwrapString: String {
            guard isShouldUseDefaultValueWhileTranlateFromModel else {
                return ""
            }
            return " ?? \(defaultValue)"
        }
        
        var unsafelyUnwrappedString: String {
            guard isShouldUnwrapWhileTranlateFromModel else {
                return ""
            }
            return ".unsafelyUnwrapped"
        }
        
        // MARK: - Useful
        
        func initString(for translateType: TranslateType) -> ((String) -> String)? {
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
        
        func translate(with translateType: TranslateType, valuePath: String) -> String {
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
                let defaultValueUnwrapString = translateType == .fromModelToPlain ? defaultValueUnwrapString : ""
                return "\(valuePath)\(defaultValueUnwrapString)"
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
}
