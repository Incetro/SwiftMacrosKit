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
            isShouldUseRealmProperty || isEnumType || initialType == "URL?"
        }
        
        var isShouldUnwrapWhileTranlateFromModel: Bool {
            isEnumType || initialType == "URL"
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
    }
}
