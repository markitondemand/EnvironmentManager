//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation


// MARK: - Exposing Storyboard
extension UIStoryboard {
    /// The name of the storyboard this belong to. you can segue to a Storyboad using this identifier
    static let environmentManagerStoryboardName = "EnvironmentManagerStoryboard"
    
    /// The storyboard that the EnvironmentManager uses for UI
    static var environmentManagerStoryboard: UIStoryboard {
        return UIStoryboard(name: UIStoryboard.environmentManagerStoryboardName, bundle: BundleAccessor().resourceBundle)
    }
}

extension UIStoryboardSegue {
    /// Helper method if using storyboards for passing the EnvironmentManager into the view controller
    ///
    /// - Parameter environmentManager: The data to pass
    public func pass(environmentManager: EnvironmentManager) {
        guard let destination = self.destination as? EnvironmentManagerPassable else {
            return
        }
        destination.pass(environmentManager: environmentManager)
    }
}

/// Implement this protocol method somewhere in your application where you presented this UI from to allow the environment manager to unwind. This function will be called when the presented viewcontroller unwinds
public protocol Unwindable {
    
    /// The UI will call this method as an exit when dismissing
    ///
    /// - Parameter segue: The segue
    func unwind(toExit segue:UIStoryboardSegue)
}

// MARK: - Generate view controller
extension EnvironmentManager {
    
    /// Use this method to create a viewcontroller programatically to present in your UI. It will use the current environment manager.
    /// - Note: You will need to wrap this in your own UINavigationController instance or things will not work properly
    ///
    /// - Returns: A new viewcontroller to present.
    public func generateViewController() -> UIViewController {
        let controller = UIStoryboard.environmentManagerStoryboard.instantiateInitialViewController() as! EnvironmentManagerViewcontroller
        controller.pass(environmentManager: self)
        
        return controller
    }
}
