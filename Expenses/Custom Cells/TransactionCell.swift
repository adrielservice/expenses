//
//  TransactionCell.swift
//  Expenses
//
//  Created by Beilis, David on 2019-09-06.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    @IBOutlet public weak var amountLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var summaryLabel: UILabel!
    @IBOutlet public weak var paidSwitch: UISwitch!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
