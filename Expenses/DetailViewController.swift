//
//  DetailViewController.swift
//  Expenses
//
//  Created by Beilis, David on 2019-08-14.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit
import Eureka
import CoreData

class DetailViewController: FormViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil

    func configureView() {
        // Update the user interface for the detail item.
        form +++
            
            Section()
            
                <<< SwitchRow() {
                    $0.tag = "paidSwitch"
                    $0.value = detailItem?.isPaid
                    $0.cellProvider = CellProvider<SwitchCell>(nibName: "PaidSwitchCell", bundle: Bundle.main)
                }.cellSetup { (cell, row) in
                    cell.height = { 67 }
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                }
            
                <<< DateRow() {
                    $0.tag = "timestamp"
                    $0.title = "Timestamp"
                    $0.value = detailItem?.timestamp
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                }
            
                <<< DecimalRow(){
                    $0.tag = "amount"
                    $0.useFormatterDuringInput = true
                    $0.title = "Amount"
                    $0.value = detailItem?.amount
                    let formatter = CurrencyFormatter()
                    formatter.locale = .current
                    formatter.numberStyle = .currency
                    $0.formatter = formatter
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                    cell.textField?.textColor = UIColor.label
                }
            
                <<< TextRow() {
                    $0.tag = "summary"
                    $0.title = "Summary"
                    $0.value = detailItem?.summary
                }.cellUpdate { (cell, row) in
                    cell.textLabel?.textColor = UIColor.secondaryLabel
                    cell.textField?.textColor = UIColor.label
                }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove excess separator lines on non-existent cells
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        do {
            
            let switchRow: SwitchRow? = form.rowBy(tag: "paidSwitch")
            detailItem?.isPaid = switchRow?.value ?? false
            
            let dateRow: DateRow? = form.rowBy(tag: "timestamp")
            detailItem?.timestamp = dateRow?.value
            
            let amountRow: DecimalRow? = form.rowBy(tag: "amount")
            detailItem?.amount = amountRow?.value ?? 0
            
            let summaryRow: TextRow? = form.rowBy(tag: "summary")
            detailItem?.summary = summaryRow?.value
            
            try self.managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    var detailItem: Event? {
        didSet {
            configureView()
        }
    }
    
    class CurrencyFormatter : NumberFormatter, FormatterProtocol {
        override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
            guard obj != nil else { return }
            var str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if !string.isEmpty, numberStyle == .currency && !string.contains(currencySymbol) {
                // Check if the currency symbol is at the last index
                if let formattedNumber = self.string(from: 1), String(formattedNumber[formattedNumber.index(before: formattedNumber.endIndex)...]) == currencySymbol {
                    // This means the user has deleted the currency symbol. We cut the last number and then add the symbol automatically
                    str = String(str[..<str.index(before: str.endIndex)])
                    
                }
            }
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        }
        
        func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
            return textInput.position(from: position, offset:((newValue?.count ?? 0) - (oldValue?.count ?? 0))) ?? position
        }
    }

}

