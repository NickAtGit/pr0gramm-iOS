
import Static

class SettingsViewController: TableViewController {
    
    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Einstellungen"
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        tabBarItem = UITabBarItem(title: "Einstellungen",
                                  image: UIImage(systemName: "gear"),
                                  selectedImage: nil)

        
        dataSource = DataSource(tableViewDelegate: nil)
        dataSource.sections = [
            Section(header: .autoLayoutView(CustomExtremityView("Theme", uppercased: false)), rows: [
                Row(cellClass: ThemeSelectionCell.self)
            ], footer: ""),
            
            Section(header: .autoLayoutView(CustomExtremityView("Video", uppercased: false)), rows: [
                Row(text: "Videos stumm starten", accessory: .switchToggle(value: AppSettings.isVideoMuted) {
                    AppSettings.isVideoMuted = $0
                }, cellClass: MultiLineTableViewCell.self)
            ], footer: ""),
        ]
    }
}



class CustomExtremityView: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(_ string: String, uppercased: Bool = false) {
        super.init(frame: .zero)
        layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        addSubview(label)
        label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        label.text = uppercased ? string.uppercased() : string
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class MultiLineTableViewCell: UITableViewCell, Cell {

    // MARK: - Properties

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - CellType

    func configure(row: Row) {
        accessibilityIdentifier = row.accessibilityIdentifier
        label.text = row.text
        detailTextLabel?.text = row.detailText
        imageView?.image = row.image
        accessoryType = row.accessory.type
        accessoryView = row.accessory.view
    }
}
