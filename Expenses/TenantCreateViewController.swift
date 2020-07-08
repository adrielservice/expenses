//
//  TenantCreateViewController.swift
//  TeleExpense
//
//  Created by Beilis, David on 2020-07-01.
//  Copyright © 2020 Adriel Service. All rights reserved.
//

import UIKit
import Eureka
import CoreData

class TenantCreateViewController : FormViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var account : Account? = nil
    
    func configureView() {
        // Update the user interface for the detail item.
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = UIColor.secondaryLabel
        }
        
        form
            +++ Section("Tenant Info")
                <<< TextRow() {
                    $0.tag = "tenantName"
                    $0.title = "Name"
                }
                <<< PhoneRow() {
                    $0.tag = "tenantPhone"
                    $0.title = "Phone"
                }
                <<< EmailRow() {
                    $0.tag = "tenantEmail"
                    $0.title = "Email"
                }
                <<< TextRow() {
                    $0.tag = "tenantDriverLicense"
                    $0.title = "Driver's License"
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    /*
        State machine
     
            APPLIED
                Actions:
                    -> Execute background check
                -> Rejected
                -> Approved
                    Actions:
                        -> Sign agreement
                        -> Receive deposit / payment
                    -> LeaseStarted (Deposit is collected)
                        Actions:
                            -> adjustLease: Rent Increase
                            -> Maintenance: call handyman / Garbage / furnice
                    -> LeaseTerminated
     */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            let tenantNameRow: TextRow? = form.rowBy(tag: "tenantName")
            let name = tenantNameRow!.value
            if ((name != nil) && !name!.isEmpty) {
                let tenant = Tenant(context: self.managedObjectContext!)
                tenant.account = account
                tenant.name = name
                
                let phoneRow: PhoneRow? = form.rowBy(tag: "tenantPhone")
                tenant.phone = phoneRow?.value
                
                let emailRow: EmailRow? = form.rowBy(tag: "emailPhone")
                tenant.email = emailRow?.value
                
                let driverLicenseRow: TextRow? = form.rowBy(tag: "tenantDriverLicense")
                tenant.driverLicense = driverLicenseRow?.value

                tenant.appliedDate = Date()
                tenant.status = "APPLIED"
                
                try self.managedObjectContext?.save()
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
}
