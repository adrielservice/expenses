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
        
        form +++
            
            Section("Info")
            
                <<< TextRow() {
                    $0.tag = "tenantName"
                    $0.title = "Tenant Name"
                    $0.value = account?.name
                }
            
                <<< TextRow() {
                    $0.tag = "address"
                    $0.title = "Address"
                    $0.value = account?.address
                }
        
                <<< DateRow() {
                    $0.tag = "startDate"
                    $0.title = "Start date"
                    $0.value = account?.startDate
                }
            
                <<< TextRow() {
                    $0.tag = "status"
                    $0.title = "Status"
                    $0.value = account?.status
                }
        
            Section("Actions")
                <<< ButtonRow() {
                    $0.tag = "actionBill"
                    $0.title = "New Bill"
                }
                <<< ButtonRow() {
                    $0.tag = "actionVerifyTenant"
                    $0.title = "Verify Tenant"
                }
                <<< ButtonRow() {
                    $0.tag = "actionStartLease"
                    $0.title = "Start Lease"
                }
                <<< ButtonRow() {
                    $0.tag = "actionCloseLease"
                    $0.title = "Close Lease"
                }

            Section("History")
                // Add history as a multivalued section
        
    }
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
