//
//  DAOMacro.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 10.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

// MARK: - DAOMacro

public struct DAOMacro: MemberMacro {

    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        return [DeclSyntax(stringLiteral: "")]
    }
}
