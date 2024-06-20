//
//  PokemonController.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/12/24.
//

import UIKit

let resuableIndentifier = "pokemonCell"

class PokemonController: UICollectionViewController, UISearchBarDelegate {
    
    var pokemons = [Pokemon]()
    var filteredPokemons = [Pokemon]()
    var isSearchActive = false
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search Pokemon"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
        fetchPokemons()
    }
    
    @objc func searchTapped() {
        if isSearchActive {
            
            isSearchActive = false
            searchBar.text = ""
            filteredPokemons = pokemons
            navigationItem.titleView = nil
            collectionView.reloadData()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchTapped))
        } else {
           
            isSearchActive = true
            navigationItem.titleView = searchBar
            searchBar.becomeFirstResponder()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(searchTapped))
        }
    }
    
    @objc func bookmarkTapped() {
        let bookmarkVC = BookmarkViewController()
        navigationController?.pushViewController(bookmarkVC, animated: true)
    }
    
    func configureViewComponents() {
        collectionView.backgroundColor = .systemBackground
        navigationController?.navigationBar.barTintColor = UIColor.mainColor
        navigationController?.navigationBar.isTranslucent = true
        
        self.title = "포켓몬 도감"
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchTapped))
        let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(bookmarkTapped))
        
        //navigationItem.rightBarButtonItems = [bookmarkButton, searchButton]
        navigationItem.rightBarButtonItem = searchButton
        navigationItem.leftBarButtonItem = bookmarkButton
        
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: resuableIndentifier)
        
        searchBar.delegate = self
    }
    
    func fetchPokemons() {
        PokemonService.shared.fetchPokemon { (pokemons, error) in
            if let error = error {
                print("Failed to fetch pokemons:", error)
                return
            }
            
            guard let pokemons = pokemons else { return }
            self.pokemons = pokemons
            self.filteredPokemons = pokemons
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearchActive = false
            filteredPokemons = pokemons
        } else {
            isSearchActive = true
            filteredPokemons = pokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
        searchBar.text = ""
        filteredPokemons = pokemons
        searchBar.resignFirstResponder()
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(bookmarkTapped)), UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchTapped))]
        collectionView.reloadData()
    }
}

extension PokemonController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPokemons.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resuableIndentifier, for: indexPath) as! PokemonCell
        
        let pokemon = filteredPokemons[indexPath.item]
        cell.pokemon = pokemon

        // PokeAPI에서 포켓몬 이미지 가져오기
        let pokemonNumber = extractPokemonNumber(from: pokemon.url)
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
        if let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pokemon = filteredPokemons[indexPath.item]
        let detailController = PokemonDetailController()
        detailController.pokemon = pokemon
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    private func extractPokemonNumber(from url: String) -> Int {
        let components = url.split(separator: "/")
        if let numberString = components.last, let number = Int(numberString) {
            return number
        }
        return 0
    }
}

extension PokemonController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 36) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8)
    }
}
