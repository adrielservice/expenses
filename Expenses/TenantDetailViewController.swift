//
//  TenantDetailViewController.swift
//  TeleExpense
//
//  Created by Beilis, David on 2020-07-01.
//  Copyright © 2020 Adriel Service. All rights reserved.
//

import UIKit
import Eureka
import CoreData
import MessageUI

class TenantDetailViewController : FormViewController  {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var tenant: Tenant? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        
        form
            +++ Section("Info")
                <<< LabelRow() {
                    $0.tag = "tenantName"
                    $0.title = "Name"
                    $0.value = tenant?.name
                }
                <<< LabelRow() {
                    $0.tag = "tenantPhone"
                    $0.title = "Phone"
                    $0.value = tenant?.phone
                }
                <<< LabelRow() {
                    $0.tag = "tenantDriversLicense"
                    $0.title = "Driver's License"
                    $0.value = tenant?.driverLicense
                }
                <<< LabelRow() {
                    $0.tag = "tenantStatus"
                    $0.title = "Status"
                    $0.value = tenant?.status
                }
                <<< LabelRow() {
                    $0.tag = "appliedDate"
                    $0.title = "Applied on"
                    $0.value = tenant?.appliedDate?.description
                }
                <<< LabelRow() {
                    $0.tag = "leaseStartDate"
                    $0.title = "Lease started on"
                    $0.value = tenant?.leaseStartDate?.description
                    $0.hidden = Condition(booleanLiteral:(tenant?.status != "LEASE_STARTED" && tenant?.status != "LEASE_ENDED"))
                }
                <<< LabelRow() {
                    $0.tag = "leaseEndDate"
                    $0.title = "Lease ended on"
                    $0.value = tenant?.leaseEndDate?.description
                    $0.hidden = Condition(booleanLiteral:(tenant?.status != "LEASE_ENDED"))
                }
            
            +++ Section("Communication")
                <<< ButtonRow() {
                    $0.tag = "actionCall"
                    $0.title = "Call"
                    $0.onCellSelection(self.handleCallTenant)
                }
                <<< ButtonRow() {
                    $0.tag = "actionMessage"
                    $0.title = "Message"
                    $0.onCellSelection(self.handleMessageTenant)
                }
                <<< ButtonRow() {
                    $0.tag = "actionEmail"
                    $0.title = "Email"
                    $0.onCellSelection(self.handleEmailTenant)
                }
                
            +++ Section("Actions")
                <<< ButtonRow() {
                    $0.tag = "actionStartLease"
                    $0.title = "Start Lease"
                    $0.onCellSelection(self.handleLeaseStart)
                    $0.hidden = Condition(booleanLiteral:(tenant?.status != "APPLIED"))
                }
                <<< ButtonRow() {
                    $0.tag = "actionTenantTxns"
                    $0.title = "View Transactions"
                    $0.onCellSelection(self.handleViewTenantTxns)
                    $0.hidden = Condition(booleanLiteral:(tenant?.status != "LEASE_STARTED" && tenant?.status != "LEASE_ENDED"))
                }
                <<< ButtonRow() {
                    $0.tag = "actionCloseLease"
                    $0.title = "End Lease"
                    $0.onCellSelection(self.handleLeaseEnd)
                    $0.hidden = Condition(booleanLiteral:(tenant?.status != "LEASE_STARTED"))
                }
                <<< ButtonRow() {
                    $0.tag = "deleteTenant"
                    $0.title = "Delete"
                    $0.onCellSelection(self.handleDelete)
                }
    }
    
    func handleCallTenant(_: ButtonCellOf<String>, _: ButtonRow) {
        let url:NSURL = URL(string: "TEL://" + tenant!.phone!)! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    
    func handleEmailTenant(_: ButtonCellOf<String>, _: ButtonRow) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients([tenant!.email!])
            mail.setMessageBody("<h1>Hello there, This is a test.<h1>", isHTML: true)
            present(mail, animated: true)
        } else {
            print("Cannot send email")
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
    
    func handleMessageTenant(_: ButtonCellOf<String>, _: ButtonRow) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hi from TeleExpense"
            controller.recipients?.append(tenant!.phone!)
            controller.messageComposeDelegate = self as? MFMessageComposeViewControllerDelegate
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func handleLeaseEnd(_: ButtonCellOf<String>, _: ButtonRow) {
        tenant?.leaseEndDate = Date()
        tenant?.status = "LEASE_ENDED"
        updateTenant()
    }
    
    func handleLeaseStart(_: ButtonCellOf<String>, _: ButtonRow) {
        tenant?.leaseStartDate = Date()
        tenant?.status = "LEASE_STARTED"
        updateTenant()
    }
    
    func handleDelete(_: ButtonCellOf<String>, _: ButtonRow) {
        if (tenant != nil) {
            self.managedObjectContext?.delete(tenant!)
            do {
              try self.managedObjectContext?.save()
          } catch {
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateTenant() {
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
    
    func handleViewTenantTxns(_: ButtonCellOf<String>, _: ButtonRow) {
        self.performSegue(withIdentifier: "viewTenantTxns", sender: self)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewTenantTxns") {
            let controller = segue.destination as! TxnsViewController
            controller.managedObjectContext = self.managedObjectContext
            controller.account = tenant?.account
            controller.tenant = tenant
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

}
