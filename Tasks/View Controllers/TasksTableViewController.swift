//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Chris Gonzales on 2/24/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
//    var tasks: [Task] {
//        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//        do{
//            return try CoreDataStack.shared.mainContext.fetch(fetchRequest)
//        } catch {
//            NSLog("Error fetching tasks: \(error)")
//            return []
//        }
//    }
    
    lazy var fetchedResultController: NSFetchedResultsController<Task> = {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "priority",
                                                         ascending: true),
                                        NSSortDescriptor(key: "name",
                                                         ascending: true)]
        let context = CoreDataStack.shared.mainContext
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: "priority",
                                             cacheName: nil)
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        return fetchResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell()}
        cell.task = fetchedResultController.object(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultController.sections?[section] else {
            return nil
        }
        return sectionInfo.name.capitalized
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultController.object(at: indexPath)
            CoreDataStack.shared.mainContext.delete(task)
            do {
                try CoreDataStack.shared.mainContext.save()
                tableView.deleteRows(at: [indexPath],
                with: .fade)
            } catch {
                CoreDataStack.shared.mainContext.reset()
                NSLog("Error saving managed object context: \(error)")
            }
            
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetailSegue" {
            if let detailVC = segue.destination as? TaskDetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailVC.task = fetchedResultController.object(at: indexPath)
                }
            }
        }
    }
}

extension TasksTableViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath],
                                 with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath],
                                 with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath],
                                 with: .automatic)
            tableView.insertRows(at: [newIndexPath],
                                 with: .automatic)
        case .delete:
            guard let oldIndexPath = indexPath else { return }
            tableView.deleteRows(at: [oldIndexPath],
                                 with: .automatic)
        @unknown default:
            break
        }
    }
}
