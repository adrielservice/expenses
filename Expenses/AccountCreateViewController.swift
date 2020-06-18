//
//  AccountCreateViewController.swift
//  TeleExpense
//
//  Created by Beilis, David on 2020-06-10.
//  Copyright © 2020 Adriel Service. All rights reserved.
//

import UIKit
import Eureka
import CoreData

class AccountCreateViewController : FormViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    
    func configureView() {
        // Update the user interface for the detail item.
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = UIColor.secondaryLabel
        }
        
        form
            +++ Section("Account Info")
                <<< TextRow() {
                    $0.tag = "accountName"
                    $0.title = "Name"
                }
                <<< TextRow() {
                    $0.tag = "accountAddress"
                    $0.title = "Address"
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        do {
            let account = Account(context: self.managedObjectContext!)
            let accountNameRow: TextRow? = form.rowBy(tag: "accountName")
            account.name = accountNameRow?.value
            
            let addressRow: TextRow? = form.rowBy(tag: "accountAddress")
            account.address = addressRow?.value
            
            account.createDate = Date()
            account.status = "CREATED"
            
            try self.managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
}
