//
//  AccountCell.swift
//  TeleExpense
//
//  Created by Beilis, David on 2020-06-10.
//  Copyright © 2020 Adriel Service. All rights reserved.
//

import UIKit
import CoreData

class AccountCell: UITableViewCell {
    
    public var listController: AccountsViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var statusLabel: UILabel!
    @IBOutlet public weak var addressLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        nameLabel.text = account?.name
        statusLabel.text = account?.status
        addressLabel.text = account?.address
    }
    
}
