
import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coordinator = Coordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = coordinator.startViewController()
        window?.makeKeyAndVisible()
        Theming.applySelectedPersistedTheme()

        //Play audio when ringer switch is silent
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)

        return true
    }
}
