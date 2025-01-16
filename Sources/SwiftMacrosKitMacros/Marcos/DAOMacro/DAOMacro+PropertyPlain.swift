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
        
        func plainValueInitString(valuePath: String) -> String {
            switch modelType {
            case .stringEnum, .intEnum:
                let initString: (String) -> String = { value in
                    "\(clearTypeName)(rawValue: \(value)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                }
                return isArray ? "\(valuePath).compactMap({ \(initString("$0")) })" : initString(valuePath)
            case .primitive:
                switch clearTypeName {
                case "URL":
                    let initString: (String) -> String = { value in
                        "\(clearTypeName)(string: \(valuePath)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                    }
                    return isArray ? "\(valuePath).compactMap({ \(initString("$0")) })" : initString(valuePath)
                default:
                    return "\(valuePath)\(defaultValueUnwrapString)"
                }
            case .plain:
                let translatorInitString = "Translator(configuration: configuration)"
                let checkNilString = "\(valuePath) == nil ? nil :"
                let translateString = "translate(\(isArray ? "models: Array(\(valuePath))" : "model: \(valuePath).unsafelyUnwrapped"))"
                return (isOptional ? checkNilString : "") + "try \(clearTypeName).\(translatorInitString).\(translateString)"
            }
        }
        
        func modelValueInitString(valuePath: String) -> String {
            switch modelType {
            case .stringEnum, .intEnum:
                let initString: (String) -> String = { value in
                    "\(clearTypeName)(rawValue: \(value)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                }
                return isArray ? "\(valuePath).compactMap({ \(initString("$0")) })" : initString(valuePath)
            case .primitive:
                switch clearTypeName {
                case "URL":
                    let initString: (String) -> String = { value in
                        "\(clearTypeName)(string: \(valuePath)\(defaultValueUnwrapString))\(unsafelyUnwrappedString)"
                    }
                    return isArray ? "\(valuePath).compactMap({ \(initString("$0")) })" : initString(valuePath)
                default:
                    return "\(valuePath)\(defaultValueUnwrapString)"
                }
            case .plain:
                let translatorInitString = "Translator(configuration: configuration)"
                let checkNilString = "\(valuePath) == nil ? nil :"
                let translateString = "translate(\(isArray ? "models: Array(\(valuePath))" : "model: \(valuePath).unsafelyUnwrapped"))"
                return (isOptional ? checkNilString : "") + "try \(clearTypeName).\(translatorInitString).\(translateString)"
            }
        }
    }
}
