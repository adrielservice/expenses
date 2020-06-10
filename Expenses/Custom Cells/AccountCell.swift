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
    
    public var listController: AccountsViewControllerTableViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var detailItem: Account? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
       
    }
    
}
