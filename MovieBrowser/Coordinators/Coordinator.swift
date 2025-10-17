//
//  Coordinator.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import Foundation
import UIKit

@MainActor
protocol Coordinator: AnyObject {
    func start()
}

@MainActor
final class SearchCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let searchAPI: SearchAPIProtocol
    
    init(navigationController: UINavigationController, searchAPI: SearchAPIProtocol) {
        self.navigationController = navigationController
        self.searchAPI = searchAPI
    }
    
    func start() {
        let viewModel = SearchViewModel(api: searchAPI)
        let searchVC = SearchViewController(
            viewModel: viewModel,
            onSelectMovie: { [weak self] movie in
                self?.showMovieDetails(for: movie)
            }
        )
        
        baseNavigationController().pushViewController(searchVC, animated: true)
    }
    
    func showMovieDetails(for movie: Movie) {
        let vm = MovieDetailsViewModel(movie: movie)
        let vc = MovieDetailsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func baseNavigationController() -> UINavigationController {
        navigationController.edgesForExtendedLayout = []
        navigationController.extendedLayoutIncludesOpaqueBars = false
        navigationController.setNavigationBarHidden(false, animated: false)
        
        navigationController.view.backgroundColor = .clear
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationBar.barTintColor = .systemBlue
        
        return navigationController
    }
}


