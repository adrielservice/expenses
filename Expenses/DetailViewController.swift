//
//  DetailViewController.swift
//  Expenses
//
//  Created by Beilis, David on 2019-08-14.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit
import Eureka

class DetailViewController: FormViewController {

    func configureView() {
        // Update the user interface for the detail item.
        
        // Do any additional setup after loading the view.
        //        configureView()
        
        form +++
            
            Section()
            
                <<< SwitchRow() {
                    $0.cellProvider = CellProvider<SwitchCell>(nibName: "PaidSwitchCell", bundle: Bundle.main)
                    }.cellSetup { (cell, row) in
                        cell.height = { 67 }
                }
            
                <<< DateRow() {
                    $0.title = "Timestamp"
                    $0.value = detailItem?.timestamp
                }
            
            
                <<< SwitchRow() {
                    $0.cellProvider = CellProvider<SwitchCell>(nibName: "AutoPaymentCell", bundle: Bundle.main)
                    }.cellSetup { (cell, row) in
                        cell.height = { 67 }
                }
            
                <<< DecimalRow(){
                    $0.useFormatterDuringInput = true
                    $0.title = "Amount"
                    $0.value = detailItem?.amount
                    let formatter = CurrencyFormatter()
                    formatter.locale = .current
                    formatter.numberStyle = .currency
                    $0.formatter = formatter
                }
            
                <<< TextRow() {
                    $0.title = "Summary"
                    $0.value = detailItem?.summary
                }
            
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove excess separator lines on non-existent cells
        tableView.tableFooterView = UIView()
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
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

