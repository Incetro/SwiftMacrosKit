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
        
        var shouldUseRealmProperty: Bool {
            (numericTypes.contains(realmSupportedType) || modelType == .intEnum)
            && (isOptional || !isOptional && realmSupportedDefaultValue == nil)
            && !isArray
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
        
        var isOptionalInDatabaseModel: Bool {
            shouldUseRealmProperty || (isOptional && typeName == "URL") || modelType == .stringEnum
        }
        
        var typeName: String {
            initialType
                .trimmingCharacters(in: CharacterSet(charactersIn: "[]?"))
                .trimmingCharacters(in: CharacterSet(charactersIn: "?"))
        }
        
        // MARK: - Useful
        
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
        
        var optionalUnwrapString: String {
            guard isOptionalInDatabaseModel else {
                return ""
            }
            return " ?? \(defaultValue)"
        }
    }
}
