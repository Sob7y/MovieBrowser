//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Mohamed Khaled on 15/10/2025.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let viewModel: SearchViewModel
    private let onSelectMovie: (Movie) -> Void
    
    // initializer that the coordinator calls
    init(viewModel: SearchViewModel, onSelectMovie: @escaping (Movie) -> Void) {
        self.viewModel = viewModel
        self.onSelectMovie = onSelectMovie
        super.init(nibName: String(describing: SearchViewController.self), bundle: .main)
    }
    
    // Required by UIKit when using storyboards (we’re not)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAccessibility()
        loadCachedData()
        setupUi()
        registerTableViewCells()
        setupTableView()
        
        self.viewModel.onMoviesChanged = { [weak self] _ in
            self?.setLoadingFooter(false)
            self?.tableView.reloadData()
        }
        self.viewModel.onError = { [weak self] message in
            self?.setLoadingFooter(false)
            self?.showAlert(message: message.errorDescription ?? "")
        }
    }
    
}

// MARK: - Private Func
extension SearchViewController {
    private func registerTableViewCells() {
        self.tableView.register(
            UINib(nibName: MovieTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: MovieTableViewCell.identifier)
    }
    
    private func setupUi() {
        title = "Search"
        view.backgroundColor = .systemBackground
        // Search bar
        searchBar.placeholder = "Search movies"
        searchBar.delegate = self
    }
    
    private func loadCachedData() {
        if let last = UserDefaults.standard.string(forKey: Constants.Keys.lastQuery), !last.isEmpty {
            searchBar.text = last
        }
        viewModel.loadInitialContent()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setLoadingFooter(_ loading: Bool) {
        Task { @MainActor in
            if loading {
                let spinner = UIActivityIndicatorView(style: .medium)
                spinner.startAnimating()
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
                tableView.tableFooterView = spinner
            } else {
                tableView.tableFooterView = UIView(frame: .zero)
            }
        }
    }
    
    private func setupAccessibility() {
        searchBar.searchTextField.accessibilityIdentifier = "search.searchField"
        tableView.accessibilityIdentifier = "search.table"
    }
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.onMoviesChanged == nil ? 0 : viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.identifier,
            for: indexPath) as? MovieTableViewCell
        else { return UITableViewCell() }
        
        let movie = self.viewModel.movies[indexPath.row]
        cell.configure(with: movie, isFavorite: viewModel.isFavorite(movie))
        
        cell.onToggleFavorite = { [weak self] in
            guard let self else { return }
            self.viewModel.toggleFavorite(movie)
            if let visible = tableView.indexPath(for: cell), visible == indexPath {
                cell.configure(with: movie, isFavorite: self.viewModel.isFavorite(movie))
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = 5 // when 5 rows from bottom, fetch next page
        if indexPath.row >= viewModel.movies.count - threshold, viewModel.hasMore, !viewModel.isBusy {
            setLoadingFooter(true)
            Task { await viewModel.loadNextPageIfNeeded() }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectMovie(viewModel.movies[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // simple debounce-ish: trigger after small delay
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(triggerSearch), object: nil)
        perform(#selector(triggerSearch), with: nil, afterDelay: 0.35)
    }
    
    @objc private func triggerSearch() {
        viewModel.search(query: searchBar.text ?? "")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
