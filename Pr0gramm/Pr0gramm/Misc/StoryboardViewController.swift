
import UIKit

public protocol StoryboardViewController: class {
    static var storyboardName: String {get}
    static var storyboardIdentifier: String {get}
    static var bundle: Bundle {get}

    static func fromStoryboard() -> Self
}

public extension StoryboardViewController {
    static var storyboardName: String {
        return String(describing: self)
    }

    static var storyboardIdentifier: String {
        return String(describing: self)
    }

    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
}

public protocol Storyboarded: StoryboardViewController {}

public extension Storyboarded {
    static func fromStoryboard() -> Self {
        return UIStoryboard(name: self.storyboardName, bundle: bundle).instantiateInitialViewController() as! Self
    }
}

public protocol StoryboardEmbeddedViewController: StoryboardViewController {
    associatedtype StoryboardEmbeddingViewController: UIViewController
    var embeddingViewController: StoryboardEmbeddingViewController {get}
}

public extension StoryboardEmbeddedViewController where Self: UIViewController, StoryboardEmbeddingViewController: UINavigationController {
    var embeddingViewController: StoryboardEmbeddingViewController {
        return self.navigationController as! StoryboardEmbeddingViewController
    }

    static func fromStoryboard() -> Self {
        let embeddingViewController = UIStoryboard(name: self.storyboardName, bundle: bundle).instantiateInitialViewController() as! UINavigationController
        return embeddingViewController.topViewController as! Self
    }
}
