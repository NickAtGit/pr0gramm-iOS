
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
            
            Section(header: .autoLayoutView(CustomExtremityView("Allgemein", uppercased: false)), rows: [
                Row(text: "Gesehen Indikator anzeigen", accessory: .switchToggle(value: AppSettings.isShowSeenBagdes) {
                    AppSettings.isShowSeenBagdes = $0
                }),
                Row(text: "Datenbank", detailText: "\(ActionsManager.shared.dataBaseSize ?? "Fehler")", accessory: .none)
                
            ], footer: ""),

            Section(header: .autoLayoutView(CustomExtremityView("Video", uppercased: false)), rows: [
                Row(text: "Videos stumm starten", accessory: .switchToggle(value: AppSettings.isVideoMuted) {
                    AppSettings.isVideoMuted = $0
                }),
                
                Row(text: "Videos automatisch starten", accessory: .switchToggle(value: AppSettings.isAutoPlay) {
                    AppSettings.isAutoPlay = $0
                })
            ], footer: ""),
        ]
    }
}



class CustomExtremityView: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
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
