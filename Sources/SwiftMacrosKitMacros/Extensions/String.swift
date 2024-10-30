//
//  String.swift
//
//
//  Created by Gleb Kovalenko on 30.10.2024.
//


// MARK: - String

extension String {
    
    /// Lower cased first letter
    func lowercaseFirstLetter() -> String {
        prefix(1).lowercased().appending(dropFirst())
    }
}
