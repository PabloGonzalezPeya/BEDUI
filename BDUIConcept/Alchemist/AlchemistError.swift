//
//  AlchemistError.swift
//  BDUIConcept
//
//  Created by Pablo Gonzalez on 11/10/21.
//

import Foundation

public enum AlchemistLiteError: Error {
    case responseDeserialization
    case componentDataMissing(component: String)
    case componentDataParsing(component: String)
}
