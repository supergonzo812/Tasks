//
//  TaskTableViewCell.swift
//  Tasks
//
//  Created by Chris Gonzales on 2/25/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var task: Task? {
        didSet{
            updateViews()
        }
    }
    // MARK: - Outlets
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var completedButton: UIButton!
    
    // MARK: - Properties
    
    @IBAction func completedButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let task = task else { return }
        
        taskTitleLabel.text = task.name
    }

}
