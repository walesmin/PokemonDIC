//
//  SplashViewController.swift
//  PokemonDIC
//
//  Created by 민경빈 on 6/15/24.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        // 로고 이미지 추가
        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.backgroundColor = .clear
        view.addSubview(logoImageView)
        
        // 로딩 애니메이션 추가
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            logoImageView.widthAnchor.constraint(equalToConstant: 300),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20)
        ])
        
        // 1.5초 후에 메인 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let pokemonController = PokemonController(collectionViewLayout: UICollectionViewFlowLayout())
            let rootViewController = UINavigationController(rootViewController: pokemonController)
            rootViewController.modalTransitionStyle = .crossDissolve
            rootViewController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = rootViewController
                window.makeKeyAndVisible()
            }
        }
    }
}

