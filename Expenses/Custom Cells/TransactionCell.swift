//
//  TransactionCell.swift
//  Expenses
//
//  Created by Beilis, David on 2019-09-06.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit
import CoreData

class TransactionCell: UITableViewCell {
    
    static var dateFormatter: DateFormatter? = nil
    static var currencyFormatter: NumberFormatter? = nil
    static let calendar = Calendar.current
    
    var managedObjectContext: NSManagedObjectContext? = nil
    public var listController: MasterViewController? = nil
    
    // dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
    static func initStaticVars() {
        dateFormatter = DateFormatter()
        // dateFormatter?.dateStyle = DateFormatter.Style.short //Set date style
        dateFormatter?.dateFormat = "MM/dd"
        dateFormatter?.timeZone = .current
    
        currencyFormatter = NumberFormatter()
        currencyFormatter?.usesGroupingSeparator = true
        currencyFormatter?.numberStyle = .currency
        currencyFormatter?.locale = Locale.current
    }
    
    @IBOutlet public weak var amountLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var frequencyLabel: UILabel!
    @IBOutlet public weak var summaryLabel: UILabel!
    @IBOutlet public weak var paidSwitch: UISwitch!
    
    var detailItem: Event? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if (TransactionCell.dateFormatter == nil || TransactionCell.currencyFormatter == nil) {
            TransactionCell.initStaticVars()
        }
        
        
        let today = TransactionCell.calendar.startOfDay(for: Date())
        self.dateLabel.font = UIFont.systemFont(ofSize: self.dateLabel.font.pointSize)
        self.dateLabel.textColor = UIColor.label
        
        confirmTimestampInitializedToBeginningOfDay()
        
        self.dateLabel?.text = TransactionCell.dateFormatter?.string(from: detailItem?.timestamp! ?? today)
        if (!self.detailItem!.isPaid) {
            let timeDiff = self.detailItem!.timestamp!.timeIntervalSince(today)
            //Transaction is late
            if (timeDiff < 0) {
                self.dateLabel.textColor = UIColor.systemRed
            }
            // Transaction last day
            else if (timeDiff < 24 * 60 * 60) {
                self.dateLabel.font = UIFont.boldSystemFont(ofSize: self.dateLabel.font.pointSize)
            }
        }
        
        if (detailItem?.isPaid != true && (detailItem?.amount == nil || detailItem?.amount == 0)) {
            self.amountLabel?.text = "Not set"
            self.amountLabel?.textColor = .systemRed
        } else {
            self.amountLabel?.textColor = UIColor.label
            self.amountLabel?.text = TransactionCell.currencyFormatter?.string(from: NSNumber(value: detailItem?.amount ?? 0))
        }
        
        self.frequencyLabel?.text = ""
        if (detailItem?.repeatFrequency != "Never") {
            self.frequencyLabel?.text = detailItem?.repeatFrequency
        }
        
        self.summaryLabel?.text = detailItem?.summary
        self.paidSwitch?.isOn = detailItem?.isPaid ?? false
    }
    
    func confirmTimestampInitializedToBeginningOfDay() {
        let beginningOfDayTimestamp = TransactionCell.calendar.startOfDay(for: self.detailItem?.timestamp ?? Date())
        let timeDiff = detailItem?.timestamp?.timeIntervalSince(beginningOfDayTimestamp)
        if (timeDiff != 0) {
            detailItem?.timestamp = beginningOfDayTimestamp
            do {
                try self.managedObjectContext?.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onPaidSwitchValueChange (sender: Any?) {
        self.detailItem?.isPaid = paidSwitch.isOn
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        if (detailItem?.isPaid == true && detailItem?.repeatFrequency != "Never") {
            // add a new duplicate record
            if (listController != nil) {
                listController?.createNewEvent(event: self.detailItem)
            }
        }
        
    }

}
