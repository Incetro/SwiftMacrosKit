//
//  DAOMacro+DAOGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro+DAOGeneration

extension DAOMacro {
    
    static func makeDAOAlias(plainName: String) -> DeclSyntax {
        return DeclSyntax(stringLiteral: "")
    }
}
