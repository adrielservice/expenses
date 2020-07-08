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
    
    var account: Account? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = UIColor.secondaryLabel
        }
        
        let tenants : Array<Tenant> = (account?.tenants?.allObjects as! Array<Tenant>)
        let tenantCount = tenants.count
        
        form
            +++ Section("Info")
                <<< LabelRow() {
                    $0.tag = "accountName"
                    $0.title = "Name"
                    $0.value = account?.name
                }
                <<< LabelRow() {
                    $0.tag = "accountAddress"
                    $0.title = "Address"
                    $0.value = account?.address
                }
                <<< LabelRow() {
                    $0.tag = "accountStatus"
                    $0.title = "Status"
                    $0.value = account?.status
                }
            
            +++ Section("Tenants")
                <<< ButtonRow() {
                    if (tenantCount > 0) {
                        $0.title = tenants[0].name
                        $0.onCellSelection(self.view1stTenantDetails)
                    }
                    $0.hidden = Condition(booleanLiteral: !(tenantCount > 0))
                }
                <<< ButtonRow() {
                    if (tenantCount > 1) {
                        $0.title = tenants[1].name
                        $0.onCellSelection(self.view2ndTenantDetails)
                    }
                    $0.hidden = Condition(booleanLiteral: !(tenantCount > 1))
                }
                
            +++ Section("Actions")
                <<< ButtonRow() {
                    $0.tag = "actionNewTenant"
                    $0.title = "New Tenant"
                    $0.onCellSelection(self.addNewTenant)
                }
                <<< ButtonRow() {
                    $0.tag = "actionBill"
                    $0.title = "New Bill"
                    $0.onCellSelection(self.handleNewBill)
                }
                <<< ButtonRow() {
                    $0.tag = "actionTxns"
                    $0.title = "View Transactions"
                    $0.onCellSelection(self.handleViewTxns)
                }
                <<< ButtonRow() {
                    $0.tag = "deleteAccount"
                    $0.title = "Delete"
                    $0.onCellSelection(self.handleDelete)
                }
    }
        
    func handleViewTxns(_: ButtonCellOf<String>, _: ButtonRow) {
        self.performSegue(withIdentifier: "viewAccountTxns", sender: self)
    }
    
    func handleNewBill(_: ButtonCellOf<String>, _: ButtonRow) {

    }
    
    func addNewTenant(_: ButtonCellOf<String>, _: ButtonRow) {
        let tenants : Array<Tenant> = (account?.tenants?.allObjects as! Array<Tenant>)
        let tenantCount = tenants.count
        
        if (tenantCount < 2) {
            self.performSegue(withIdentifier: "createNewTenant", sender: self)
        } else {
            // Display message that we only support up to 2 tenants
            let alertController = UIAlertController(title: "TeleExpense", message: "At most 2 tenants are allowed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    var selectedTenant : Tenant? = nil
    
    func view1stTenantDetails(_: ButtonCellOf<String>, _: ButtonRow) {
        let tenants : Array<Tenant> = (account?.tenants?.allObjects as! Array<Tenant>)
        selectedTenant = tenants[0]
        self.performSegue(withIdentifier: "viewTenantDetails", sender: self)
    }
    
    func view2ndTenantDetails(_: ButtonCellOf<String>, _: ButtonRow) {
        let tenants : Array<Tenant> = (account?.tenants?.allObjects as! Array<Tenant>)
        selectedTenant = tenants[1]
        self.performSegue(withIdentifier: "viewTenantDetails", sender: self)
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
    
    func handleDelete(_: ButtonCellOf<String>, _: ButtonRow) {
        if (account != nil) {
            self.managedObjectContext?.delete(account!)
            do {
              try self.managedObjectContext?.save()
          } catch {
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "viewAccountTxns") {
            let controller = segue.destination as! TxnsViewController
            controller.managedObjectContext = self.managedObjectContext
            controller.account = account
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if (segue.identifier == "createNewTenant") {
            let controller = segue.destination as! TenantCreateViewController
            controller.managedObjectContext = self.managedObjectContext
            controller.account = account
            controller.navigationItem.leftItemsSupplementBackButton = true
        } else if (segue.identifier == "viewTenantDetails") {
            let controller = segue.destination as! TenantDetailViewController
            controller.managedObjectContext = self.managedObjectContext
            controller.tenant = selectedTenant
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        form.removeAll()
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
    
}
