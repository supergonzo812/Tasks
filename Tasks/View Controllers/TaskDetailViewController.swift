//
//  ViewController.swift
//  Tasks
//
//  Created by Chris Gonzales on 2/24/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var priorityControl: UISegmentedControl!
    @IBOutlet var completedButton: UIButton!
    
    // MARK: - Properties
    
    var task: Task?
    
    // MARK: - View Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.text = ""
        let priority: TaskPriority
        if let taskPriority = task?.priority{
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        priorityControl.selectedSegmentIndex = TaskPriority.allCases.firstIndex(of: priority) ?? 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let task = task {
            title = task.name
            nameTextField.text = task.name
            notesTextView.text = task.notes
            
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                target: self,
                                                                action: #selector(save))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let task = task {
            guard let name = nameTextField.text,
                !name.isEmpty else { return }
            let notes = notesTextView.text
            let priorityIndex = priorityControl.selectedSegmentIndex
                             let priority = TaskPriority.allCases[priorityIndex]
  
            task.name = name
            task.notes = notes
            task.priority = priority.rawValue
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
    }
    
    @objc func save() {
        guard let name = nameTextField.text,
            !name.isEmpty else { return }
        let notes = notesTextView.text
        
        let priorityIndex = priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allCases[priorityIndex]
        
        Task(name: name,
             notes: notes,
             priority: priority)
        saveTask()
        navigationController?.dismiss(animated: true,
                                      completion: nil)
    }
    
    private func saveTask() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}

