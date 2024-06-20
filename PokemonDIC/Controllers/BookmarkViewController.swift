//
//  BookmarkViewController.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/15/24.
//

import UIKit

class BookmarkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var bookmarks = [Bookmark]()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(PokemonCell.self, forCellWithReuseIdentifier: "pokemonCell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.title = "Bookmarks"
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        fetchBookmarks()
    }
    
    func fetchBookmarks() {
        FirestoreService.shared.fetchBookmarks { [weak self] (bookmarks, error) in
            if let error = error {
                print("Failed to fetch bookmarks:", error)
                return
            }
            
            self?.bookmarks = bookmarks ?? []
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pokemonCell", for: indexPath) as! PokemonCell
        
        let bookmark = bookmarks[indexPath.item]
        cell.pokemonName.text = bookmark.name
        
        if let imageUrl = URL(string: bookmark.imageUrl) {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 36) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookmark = bookmarks[indexPath.item]
        let detailController = PokemonDetailController()
        
        let pokemon = Pokemon(name: bookmark.name, url: "https://pokeapi.co/api/v2/pokemon/\(bookmark.id)/")
        detailController.pokemon = pokemon
        navigationController?.pushViewController(detailController, animated: true)
    }
}
