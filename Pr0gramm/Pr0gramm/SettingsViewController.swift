
import Static
import StoreKit

class SettingsViewController: TableViewController {
    
    convenience init() {
        self.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Einstellungen"
        tabBarItem = UITabBarItem(title: "Einstellungen",
                                  image: UIImage(systemName: "gear"),
                                  selectedImage: nil)

        dataSource = DataSource(tableViewDelegate: nil)
        dataSource.sections = [
            Section(header: .autoLayoutView(CustomExtremityView("Unterstütze mich", uppercased: true)), rows: [
                Row(text: "Downloade meine andere App", selection: { [unowned self] in
                    self.displayOverlay()
                }, cellClass: ButtonCell.self)
            ], footer: "Da ich immer wieder gefragt werde, ob und wie man mich unterstützen kann: Lade einfach meine anderen Apps herunter. Ich würde mich auch über eine (gute) Bewertung im AppStore freuen. Vielen Dank!"),
            
            Section(header: .autoLayoutView(CustomExtremityView("Theme", uppercased: true)), rows: [
                Row(cellClass: ThemeSelectionCell.self)
            ], footer: ""),
            
            Section(header: .autoLayoutView(CustomExtremityView("Anzahl der Hochlads pro Reihe", uppercased: true)), rows: [
                Row(cellClass: PostCountSelectionCell.self)
            ], footer: ""),
            
            Section(header: .autoLayoutView(CustomExtremityView("Allgemein", uppercased: true)), rows: [
                Row(text: "Gesehen Indikator anzeigen", accessory: .switchToggle(value: AppSettings.isShowSeenBagdes) {
                    AppSettings.isShowSeenBagdes = $0
                }, cellClass: SettingsCell.self),
                
                Row(text: "Nächster/Letzter Hochlad Tap aktivieren", accessory: .switchToggle(value: AppSettings.isUseLeftRightQuickTap) {
                    AppSettings.isUseLeftRightQuickTap = $0
                }, cellClass: SettingsCell.self),
                
                Row(text: "Medien auf Bildschirmhöhe begrenzen", accessory: .switchToggle(value: AppSettings.isMediaHeightLimitEnabled) {
                    AppSettings.isMediaHeightLimitEnabled = $0
                }, cellClass: SettingsCell.self),
                
                Row(text: "Datenbank", detailText: "\(ActionsManager.shared.dataBaseSize ?? "Fehler")", accessory: .none, cellClass: SettingsCell.self)
                
            ], footer: ""),

            Section(header: .autoLayoutView(CustomExtremityView("Video", uppercased: true)), rows: [
                Row(text: "Videos stumm starten", accessory: .switchToggle(value: AppSettings.isVideoMuted) {
                    AppSettings.isVideoMuted = $0
                }, cellClass: SettingsCell.self),
                
                Row(text: "Videos automatisch starten", accessory: .switchToggle(value: AppSettings.isAutoPlay) {
                    AppSettings.isAutoPlay = $0
                }, cellClass: SettingsCell.self),
                
                Row(text: "Bild in Bild Modus", accessory: .switchToggle(value: AppSettings.isPictureInPictureEnabled) {
                    AppSettings.isPictureInPictureEnabled = $0
                }, cellClass: SettingsCell.self)

            ], footer: ""),
        ]
    }
    
    private func displayOverlay() {
        guard let scene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
        if #available(iOS 14.0, *) {
            let config = SKOverlay.AppConfiguration(appIdentifier: "1249686798", position: .bottomRaised)
            let overlay = SKOverlay(configuration: config)
            overlay.present(in: scene)
        }
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

class SettingsCell: Value1Cell {
        
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        detailTextLabel?.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
