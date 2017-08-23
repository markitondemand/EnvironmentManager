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
    
    // Input
    var entryName: String?
    
    // Output
    var newEnvironment: Entry.Pair?
    
    
    override func viewDidLoad() {
        self.navigationItem.title = entryName
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
            guard let name = nameField.text,
                let urlString = urlField.text,
                let url = URL(string: urlString) else {
                    self.present(UIAlertController(title: "Error", message: "Please ensure you have a name and your URL is correct and valid.", preferredStyle: .alert), animated: true)
                    return
            }
            newEnvironment = (name, url)
        }
    }
}
