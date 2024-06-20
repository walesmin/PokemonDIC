//
//  Pokemon.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/12/24.
//

import Foundation

struct Pokemon: Decodable {
    let name: String
    let url: String
    
    var id: Int {
            let components = url.split(separator: "/")
            return Int(components.last ?? "0") ?? 0
        }
}

struct PokemonResponse: Decodable {
    let results: [Pokemon]
}
