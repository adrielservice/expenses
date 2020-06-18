//
//  AccountDetailViewController.swift
//  TeleExpense
//
//  Created by Beilis, David on 2020-06-10.
//  Copyright © 2020 Adriel Service. All rights reserved.
//

import UIKit
import Eureka
import CoreData

class AccountDetailViewController : FormViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    
    func configureView() {
        // Update the user interface for the detail item.
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = UIColor.secondaryLabel
        }
        
        form
            +++ Section("Info")
                <<< LabelRow() {
                    $0.tag = "accountName"
                    $0.title = "Name"
                    $0.value = account?.name
                }
                <<< LabelRow() {
                    $0.tag = "accountStatus"
                    $0.title = "Status"
                    $0.value = account?.status
                }
                <<< LabelRow() {
                    $0.tag = "createDate"
                    $0.title = "Created on"
                    $0.value = account?.createDate?.description
                    $0.hidden = Condition(booleanLiteral:(account?.status != "CREATED"))
                }
                <<< LabelRow() {
                    $0.tag = "startDate"
                    $0.title = "Lease started on"
                    $0.value = account?.startDate?.description
                    $0.hidden = Condition(booleanLiteral:(account?.status != "STARTED"))
                }
                <<< LabelRow() {
                    $0.tag = "endDate"
                    $0.title = "Lease ended on"
                    $0.value = account?.endDate?.description
                    $0.hidden = Condition(booleanLiteral:(account?.status != "ENDED"))
                }
                
            +++ Section("Actions")
                <<< ButtonRow() {
                    $0.tag = "actionStartLease"
                    $0.title = "Start Lease"
                    $0.onCellSelection(self.handleLeaseStart)
                    $0.hidden = Condition(booleanLiteral:(account?.status != "CREATED"))
                }
                <<< ButtonRow() {
                    $0.tag = "actionTxns"
                    $0.title = "View Transactions"
                    $0.onCellSelection(self.handleViewTxns)
                    $0.hidden = Condition(booleanLiteral:(account?.status != "STARTED" && account?.status != "ENDED"))
                }
                <<< ButtonRow() {
                    $0.tag = "actionBill"
                    $0.title = "New Bill"
                    $0.onCellSelection(self.handleNewBill)
                    $0.hidden = Condition(booleanLiteral:(account?.status != "STARTED"))
                }
                <<< ButtonRow() {
                    $0.tag = "actionCloseLease"
                    $0.title = "End Lease"
                    $0.onCellSelection(self.handleLeaseEnd)
                    $0.hidden = Condition(booleanLiteral:(account?.status != "STARTED"))
                }
    }
    
    func handleLeaseEnd(_: ButtonCellOf<String>, _: ButtonRow) {
        account?.endDate = Date()
        account?.status = "ENDED"
        updateAccount()
    }
    
    func handleLeaseStart(_: ButtonCellOf<String>, _: ButtonRow) {
        account?.startDate = Date()
        account?.status = "STARTED"
        updateAccount()
    }
    
    func handleViewTxns(_: ButtonCellOf<String>, _: ButtonRow) {

    }
    
    func handleNewBill(_: ButtonCellOf<String>, _: ButtonRow) {

    }
    
    func updateAccount() {
        do {
            try self.managedObjectContext?.save()
            form.removeAll()
            configureView()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
    
}
