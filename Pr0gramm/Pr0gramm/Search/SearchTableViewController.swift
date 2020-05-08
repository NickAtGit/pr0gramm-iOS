
import UIKit

class SearchTableViewController: UITableViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Suche"
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        tabBarItem = UITabBarItem(title: "Suche",
                                  image: UIImage(systemName: "magnifyingglass.circle"),
                                  selectedImage: UIImage(systemName: "magnifyingglass.circle.fill"))
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSettings.latestSearchStrings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTextCell")!
        cell.textLabel?.text = AppSettings.latestSearchStrings[indexPath.row]
        cell.textLabel?.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        search(searchString: AppSettings.latestSearchStrings[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Löschen",
          handler: { (action, view, completionHandler) in
            AppSettings.latestSearchStrings = AppSettings.latestSearchStrings.filter { $0 != AppSettings.latestSearchStrings[indexPath.row] }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        deleteAction.backgroundColor = UIColor.red.withAlphaComponent(0.25)
                
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        return view
    }
    
    private func search(searchString: String) {
        coordinator?.showSearchResult(for: searchString, from: self)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text,
            !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        search(searchString: searchText)

        if !AppSettings.latestSearchStrings.contains(searchText) {
            AppSettings.latestSearchStrings = [searchText] + AppSettings.latestSearchStrings
        }
        tableView.reloadData()
    }
}
