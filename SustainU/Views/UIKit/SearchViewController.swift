import UIKit

class SearchViewController: UIViewController {

    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Enter your zip code"
        bar.backgroundColor = .systemBackground
        bar.layer.cornerRadius = 10
        bar.clipsToBounds = true
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        searchBar.delegate = self
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Aquí puedes manejar la acción de búsqueda
        print("Buscando: \(searchBar.text ?? "")")
        searchBar.resignFirstResponder()
    }
}
