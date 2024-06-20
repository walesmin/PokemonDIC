//
//  PokemonService.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/12/24.
//

import Foundation

class PokemonService {
    
    static let shared = PokemonService()
    
    func fetchPokemon(completion: @escaping ([Pokemon]?, Error?) -> Void) {
        
        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=151"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: data)
                completion(pokemonResponse.results, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }.resume()
    }
    func fetchPokemonDetail(urlString: String, completion: @escaping (PokemonDetail?, Error?) -> Void) {
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
                    completion(pokemonDetail, nil)
                } catch let jsonError {
                    completion(nil, jsonError)
                }
            }.resume()
        }
    func fetchPokemonDescription(urlString: String, completion: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let pokemonSpecies = try JSONDecoder().decode(PokemonDetail.PokemonSpecies.self, from: data)
                let description = pokemonSpecies.flavor_text_entries.first { $0.language.name == "ko" }?.flavor_text
                completion(description, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }.resume()
    }
}
    

