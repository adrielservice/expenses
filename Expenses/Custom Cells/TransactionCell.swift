//
//  TransactionCell.swift
//  Expenses
//
//  Created by Beilis, David on 2019-09-06.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    static var dateFormatter: DateFormatter? = nil
    static var currencyFormatter: NumberFormatter? = nil
    
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
        
        self.dateLabel?.text = TransactionCell.dateFormatter?.string(from: detailItem?.timestamp! ?? Date())
        self.amountLabel?.text = TransactionCell.currencyFormatter?.string(from: NSNumber(value: detailItem?.amount ?? 0))
        self.summaryLabel?.text = detailItem?.summary ?? "Default summary"
        self.paidSwitch?.isOn = detailItem?.isPaid ?? false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onPaidSwitchValueChange (sender: Any?) {
        self.detailItem?.isPaid = paidSwitch.isOn
    }

}
