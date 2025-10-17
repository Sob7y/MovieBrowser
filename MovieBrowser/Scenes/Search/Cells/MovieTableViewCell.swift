//
//  MovieTableViewCell.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var movieTitleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    var onToggleFavorite: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUi()
        favoriteButton.addTarget(self, action: #selector(tapFavorite), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupUi() {
        favoriteButton.setTitleColor(.systemBlue, for: .normal)
        favoriteButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        posterImageView.backgroundColor = .tertiarySystemFill
        posterImageView.layer.cornerRadius = 8
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        
        movieTitleLabel.font = .preferredFont(forTextStyle: .headline)
        releaseDateLabel.font = .preferredFont(forTextStyle: .subheadline)
        releaseDateLabel.textColor = .secondaryLabel
        
        setupAccessibility()
    }
    
    func configure(with movie: Movie, isFavorite: Bool) {
        
        movieTitleLabel.text = movie.title
        releaseDateLabel.text = movie.formattedReleaseDate
        
        favoriteButton.setTitle(isFavorite ? "Saved" : "Save", for: .normal)
        
        posterImageView.image = nil
        if let url = movie.posterURL {
            Task { [weak self] in
                let image = try? await ImageLoader.shared.load(url)
                await MainActor.run { self?.posterImageView.image = image }
            }
        }
    }
    
    @objc private func tapFavorite() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onToggleFavorite?()
    }
    
    private func setupAccessibility() {
        movieTitleLabel.accessibilityIdentifier = "cell.title"
        releaseDateLabel.accessibilityIdentifier = "cell.date"
        posterImageView.accessibilityIdentifier = "cell.poster"
        favoriteButton.accessibilityIdentifier = "cell.favoriteButton"
    }
    
}
