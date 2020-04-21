
import UIKit

class SearchTableViewController: UITableViewController, StoryboardInitialViewController {
    
    var connector: Pr0grammConnector!
    weak var coordinator: Coordinator?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Suche"
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        tabBarItem = UITabBarItem(title: "Suche",
                                  image: UIImage(systemName: "magnifyingglass.circle"),
                                  selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSettings.latestSearchStrings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTextCell")!
        cell.textLabel?.text = AppSettings.latestSearchStrings[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showSearchResult(for: AppSettings.latestSearchStrings[indexPath.row], from: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Löschen",
          handler: { (action, view, completionHandler) in
            AppSettings.latestSearchStrings = AppSettings.latestSearchStrings.filter { $0 != AppSettings.latestSearchStrings[indexPath.row] }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        deleteAction.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
                
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
            !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        coordinator?.showSearchResult(for: searchText, from: self)
        AppSettings.latestSearchStrings = AppSettings.latestSearchStrings + [searchText]
        tableView.reloadData()
    }
}
