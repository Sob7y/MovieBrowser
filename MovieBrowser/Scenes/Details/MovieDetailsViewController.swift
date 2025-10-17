//
//  MovieDetailsViewController.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var overviewTitleLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    
    private let viewModel: MovieDetailsViewModel
    
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "MovieDetailsViewController", bundle: Bundle(for: MovieDetailsViewController.self))
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Details"
        view.backgroundColor = .systemBackground
        setupUi()
    }
    
    private func setupUi() {
        
        // Label styles
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        releaseDateLabel.font = .preferredFont(forTextStyle: .subheadline)
        releaseDateLabel.textColor = .secondaryLabel
        overviewTitleLabel.text = "Overview"
        overviewTitleLabel.font = .preferredFont(forTextStyle: .headline)
        overviewLabel.font = .preferredFont(forTextStyle: .body)
        overviewLabel.numberOfLines = 0
        
        // Poster style
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 12
        
        bindData()
        setupAccessibility()
    }
    
    // Binding data
    private func bindData() {
        titleLabel.text = viewModel.titleText
        releaseDateLabel.text = "Release date: \(viewModel.releaseDateText)"
        overviewLabel.text = viewModel.overviewText
        
        if let url = viewModel.posterURL {
            Task { [weak self] in
                let image = try? await ImageLoader.shared.load(url)
                await MainActor.run { self?.posterImageView.image = image }
            }
        } else {
            posterImageView.image = nil
        }
    }
    
    private func setupAccessibility() {
        titleLabel.accessibilityIdentifier = "details.title"
        releaseDateLabel.accessibilityIdentifier = "details.date"
        overviewLabel.accessibilityIdentifier = "details.overview"
        posterImageView.accessibilityIdentifier = "details.poster"
    }
}

