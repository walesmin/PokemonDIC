//
//  PokemonDetail.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/14/24.
//

import Foundation

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let abilities: [Ability]
    let types: [TypeElement]
    let stats: [Stat]
    
    struct Ability: Decodable {
        let ability: Species
    }
    
    struct TypeElement: Decodable {
        let type: Species
    }
    
    struct Stat: Decodable {
        let base_stat: Int
        let stat: Species
    }
    
    struct Species: Decodable {
        let name: String
    }
    
    struct PokemonSpecies: Decodable {
        let flavor_text_entries: [FlavorTextEntry]
        
        struct FlavorTextEntry: Decodable {
            let flavor_text: String
            let language: Language
        }
        
        struct Language: Decodable {
            let name: String
        }
    }
}


