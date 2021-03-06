//
//  MasterViewController.swift
//  Expenses
//
//  Created by Beilis, David on 2019-08-14.
//  Copyright © 2019 Adriel Service. All rights reserved.
//

import UIKit
import CoreData

class TxnsViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: TxnDetailViewController? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var account: Account? = nil
    
    var tenant: Tenant? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // navigationItem.leftBarButtonItem = editButtonItem

        self.tableView.rowHeight = 60
        let transactionCell = UINib(nibName: "TransactionCell", bundle: nil)
        self.tableView.register(transactionCell, forCellReuseIdentifier: "transactionCell")
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.addTarget(self, action: #selector(refreshTableData(_:)), for: .valueChanged)
        self.tableView.refreshControl!.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Fetching Transaction Data ...")

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        self.createNewEvent()
    }
    
    func createNewEvent() {
        self.performSegue(withIdentifier: "viewTxnDetails", sender: self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewTxnDetails" {
            let controller = segue.destination as! TxnDetailViewController
            controller.managedObjectContext = self.managedObjectContext
            if let indexPath = tableView.indexPathForSelectedRow {
                controller.detailItem = fetchedResultsController.object(at: indexPath)
            }
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        if (sectionInfo.name == "0") {
            return "Upcoming"
        } else if (sectionInfo.name == "1") {
            return "Paid"
        }
        
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
        cell.showsReorderControl = true
        cell.shouldIndentWhileEditing = false
        
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "viewTxnDetails", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        let transactionCell = cell as! TransactionCell
        transactionCell.detailItem = event
        transactionCell.listController = self
        transactionCell.managedObjectContext = self.managedObjectContext
    }
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        fetchRequest.fetchBatchSize = 100
        let sortTimeDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortPaidDescriptor = NSSortDescriptor(key: "isPaid", ascending: true)
        
        fetchRequest.sortDescriptors = [sortPaidDescriptor, sortTimeDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "isPaid", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    @objc
    func refreshTableData(_ sender: Any) {
        DispatchQueue.main.async {
            do {
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
                self.tableView.refreshControl!.endRefreshing()
                // self.activityIndicatorView.stopAnimating()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                let eventObj = anObject as? Event
                if (eventObj != nil) {
                    configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
                }
            case .move:
//                let cell = tableView.cellForRow(at: indexPath!)
//                configureCell(cell!, withEvent: eventObj!)
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
                
                let eventObj = anObject as? Event
                if (eventObj != nil) {
                    let cell = tableView.cellForRow(at: indexPath!)
                    if (cell != nil) {
                        configureCell(cell!, withEvent: eventObj!)
                        tableView.moveRow(at: indexPath!, to: newIndexPath!)
                    }
                }
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

