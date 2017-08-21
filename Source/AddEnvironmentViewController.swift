//  Copyright © 2017 Markit. All rights reserved.
//

import Foundation

class AddEnvironmentViewController: UITableViewController {
    private enum Cells: String {
        case environmentCell = "CustomEnvironmentCell"
    }
    
    private enum Segue: String {
        case cancel = "CancelSegue"
        case done = "DoneSegue"
    }
    
    var initialEntry: Entry!
    var newEnvironments:[ (environment: String, url: URL)] = []
    
    // Data
    var store: CustomEntryStore!
    
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segue = Segue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch segue {
        case .cancel:
            return
        case .done:
//            newEnvironments.forEach({ (<#(environment: String, url: URL)#>) in
////                store
//            })
            return
            
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.allEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return tableView.dequeueReusableCell(withIdentifier: Cells.environmentCell.rawValue)!
    }
}
