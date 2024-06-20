//
//  PokemonDetailController.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/14/24.
//

import UIKit
import FirebaseFirestore

class PokemonDetailController: UIViewController {
    
    var pokemon: Pokemon? {
        didSet {
            guard let pokemon = pokemon else { return }
            PokemonService.shared.fetchPokemonDetail(urlString: pokemon.url) { [weak self] (detail, error) in
                if let error = error {
                    print("Failed to fetch pokemon detail:", error)
                    return
                }
                
                guard let detail = detail else { return }
                DispatchQueue.main.async {
                    self?.configureViewComponents(with: detail)
                }
                
                let speciesUrlString = "https://pokeapi.co/api/v2/pokemon-species/\(detail.id)"
                PokemonService.shared.fetchPokemonDescription(urlString: speciesUrlString) { [weak self] (description, error) in
                    if let error = error {
                        print("Failed to fetch pokemon description:", error)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.descriptionLabel.text = description
                    }
                }
                
                self?.updateBookmarkStatus(for: "\(detail.id)")
            }
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 100
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.gray.cgColor
        iv.layer.borderWidth = 2
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let typesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let abilitiesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var isBookmarked = false {
        didSet {
            updateBookmarkButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(idLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(typesStackView)
        view.addSubview(statsStackView)
        view.addSubview(abilitiesStackView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            idLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            typesStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            typesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            typesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            statsStackView.topAnchor.constraint(equalTo: typesStackView.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            abilitiesStackView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 16),
            abilitiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            abilitiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        let bookmarkButton = UIBarButtonItem(image: UIImage(systemName: "bookmark"), style: .plain, target: self, action: #selector(handleBookmarkTapped))
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    func updateBookmarkButton() {
        let bookmarkIconName = isBookmarked ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: bookmarkIconName)
    }
    
    func updateBookmarkStatus(for pokemonId: String) {
        FirestoreService.shared.isBookmarked(pokemonId: pokemonId) { [weak self] isBookmarked in
            self?.isBookmarked = isBookmarked
        }
    }
    
    @objc func handleBookmarkTapped() {
        guard let pokemon = pokemon else { return }
        let pokemonNumber = extractPokemonNumber(from: pokemon.url)
        let bookmark = Bookmark(id: "\(pokemonNumber)", name: pokemon.name, imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png")
        
        if isBookmarked {
            FirestoreService.shared.removeBookmark(bookmarkId: bookmark.id) { [weak self] error in
                if let error = error {
                    print("Failed to remove bookmark:", error)
                    return
                }
                self?.isBookmarked = false
                print("Successfully removed bookmark")
            }
        } else {
            FirestoreService.shared.addBookmark(bookmark: bookmark) { [weak self] error in
                if let error = error {
                    print("Failed to add bookmark:", error)
                    return
                }
                self?.isBookmarked = true
                print("Successfully added bookmark")
            }
        }
    }
    
    func configureViewComponents(with detail: PokemonDetail) {
        nameLabel.text = detail.name.capitalized
        idLabel.text = "ID: \(detail.id)"
        
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for type in detail.types {
            let typeLabel = UILabel()
            typeLabel.text = type.type.name.capitalized
            typeLabel.font = UIFont.systemFont(ofSize: 14)
            typeLabel.textAlignment = .center
            typeLabel.backgroundColor = getColor(for: type.type.name) // 타입 색상으로 배경 설정
            typeLabel.layer.cornerRadius = 8
            typeLabel.layer.masksToBounds = true
            typeLabel.translatesAutoresizingMaskIntoConstraints = false
            typesStackView.addArrangedSubview(typeLabel)
        }
        
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                for stat in detail.stats {
                    let statStack = UIStackView()
                    statStack.axis = .horizontal
                    statStack.spacing = 10
                    statStack.alignment = .center
                    statStack.distribution = .fill
                    statStack.translatesAutoresizingMaskIntoConstraints = false
                    
                    let statLabel = UILabel()
                    statLabel.text = stat.stat.name.capitalized
                    statLabel.font = UIFont.systemFont(ofSize: 14)
                    statLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
                    statStack.addArrangedSubview(statLabel)
                    
                    let statValueLabel = UILabel()
                    statValueLabel.text = "\(stat.base_stat)"
                    statValueLabel.font = UIFont.boldSystemFont(ofSize: 16)
                    statValueLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                    statStack.addArrangedSubview(statValueLabel)
                    
                    let statProgressView = UIProgressView(progressViewStyle: .default)
                    statProgressView.progress = Float(stat.base_stat) / 255.0
                    statProgressView.tintColor = .systemBlue
                    statStack.addArrangedSubview(statProgressView)
                    
                    statsStackView.addArrangedSubview(statStack)
                }
        
        abilitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for ability in detail.abilities {
            let abilityLabel = UILabel()
            abilityLabel.text = ability.ability.name.capitalized
            abilityLabel.font = UIFont.systemFont(ofSize: 14)
            abilityLabel.textAlignment = .center
            abilityLabel.backgroundColor = UIColor.systemGray5
            abilityLabel.layer.cornerRadius = 8
            abilityLabel.layer.masksToBounds = true
            abilityLabel.translatesAutoresizingMaskIntoConstraints = false
            abilitiesStackView.addArrangedSubview(abilityLabel)
        }
        
        let pokemonNumber = detail.id
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonNumber).png"
        if let imageUrl = URL(string: imageUrlString) {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
    
    func getColor(for type: String) -> UIColor {
        switch type.lowercased() {
        case "normal":
            return UIColor.systemGray.withAlphaComponent(0.3)
        case "fighting":
            return UIColor.systemRed.withAlphaComponent(0.3)
        case "flying":
            return UIColor.systemTeal.withAlphaComponent(0.3)
        case "poison":
            return UIColor.systemPurple.withAlphaComponent(0.3)
        case "ground":
            return UIColor.brown.withAlphaComponent(0.3)
        case "rock":
            return UIColor.systemGray.withAlphaComponent(0.3)
        case "bug":
            return UIColor.systemGreen.withAlphaComponent(0.3)
        case "ghost":
            return UIColor.systemIndigo.withAlphaComponent(0.3)
        case "steel":
            return UIColor.systemGray2.withAlphaComponent(0.3)
        case "fire":
            return UIColor.systemRed.withAlphaComponent(0.3)
        case "water":
            return UIColor.systemBlue.withAlphaComponent(0.3)
        case "grass":
            return UIColor.systemGreen.withAlphaComponent(0.3)
        case "electric":
            return UIColor.systemYellow.withAlphaComponent(0.3)
        case "psychic":
            return UIColor.systemPink.withAlphaComponent(0.3)
        case "ice":
            return UIColor.systemTeal.withAlphaComponent(0.3)
        case "dragon":
            return UIColor.systemOrange.withAlphaComponent(0.3)
        case "dark":
            return UIColor.systemGray3.withAlphaComponent(0.3)
        case "fairy":
            return UIColor.systemPink.withAlphaComponent(0.3)
        default:
            return UIColor.lightGray.withAlphaComponent(0.3)
        }
    }
    
    private func extractPokemonNumber(from url: String) -> Int {
        let components = url.split(separator: "/")
        if let numberString = components.last, let number = Int(numberString) {
            return number
        }
        return 0
    }
}
