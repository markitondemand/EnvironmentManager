//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

class AddEnvironmentViewController: UIViewController {
    private enum Cells: String {
        case environmentCell = "CustomEnvironmentCell"
    }
    
    private enum Segue: String {
        case cancel = "CancelSegue"
        case done = "DoneSegue"
    }
    
    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var urlField: UITextField!
    
    // Data
//    var store: CustomEntryStore!
    var newEnvironment: Entry.Pair?
    
    
    override func viewDidLoad() {
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // TOOD: return false if we fail validation on .done
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segue = Segue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch segue {
        case .cancel:
            return
        case .done:
            // TOOD: do some validation
            guard let name = nameField.text,
                let urlString = urlField.text,
                let url = URL(string: urlString) else {
                    return
            }
            newEnvironment = (name, url)
        }
    }
}
