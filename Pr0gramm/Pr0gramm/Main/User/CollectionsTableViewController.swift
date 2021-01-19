
import UIKit

class CollectionsTableViewController: UITableViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    var viewModel: UserInfoViewModel!
      
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userInfo.value?.collections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell")!
        cell.textLabel?.text = viewModel.userInfo.value?.collections?[indexPath.row].name
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.textLabel?.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let keyword = viewModel.userInfo.value?.collections?[indexPath.row].keyword,
              let collectionName = viewModel.userInfo.value?.collections?[indexPath.row].name,
              let navigationController = navigationController,
              let name = viewModel.name.value else { return }
        coordinator?.showUserPosts(for: .collection(user: name,
                                                    name: collectionName,
                                                    keyword: keyword),
                                   navigationController: navigationController)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        return view
    }
}
