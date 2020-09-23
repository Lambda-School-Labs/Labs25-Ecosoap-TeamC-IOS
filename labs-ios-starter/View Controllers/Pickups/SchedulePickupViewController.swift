//
//  SchedulePickupViewController.swift
//  labs-ios-starter
//
//  Created by Wyatt Harrell on 8/11/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

class SchedulePickupViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var schedulePickupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var cartons: [Int] = [-1 , -1]
    
    private var soapCartons: [UUID:Int] = [:]
    private var paperCartons: [UUID:Int] = [:]
    private var linenCartons: [UUID:Int] = [:]
    private var bottleCartons: [UUID:Int] = [:]
    
    // Pickup Input Properties
    private var notes: String?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Private Methods
    private func setupViews() {
        self.hideKeyboardWhenViewTapped()
        schedulePickupButton.layer.cornerRadius = 8
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectPropertyModalSegue" {
            guard let selectPropertyVC = segue.destination as? SelectPropertyViewController else { return }
            selectPropertyVC.delegate = self
        }
    }
    
    // MARK: - IBActions
    @IBAction func schedulePickupButtonTapped(_ sender: Any) {
        
        var cartons: [CartonInput] = []
        for percentage in soapCartons.values {
            cartons.append(CartonInput(product: .SOAP, percentFull: percentage))
        }
        
        for percentage in paperCartons.values {
            cartons.append(CartonInput(product: .PAPER, percentFull: percentage))
        }
        
        for percentage in linenCartons.values {
            cartons.append(CartonInput(product: .LINENS, percentFull: percentage))
        }
        
        for percentage in bottleCartons.values {
            cartons.append(CartonInput(product: .BOTTLES, percentFull: percentage))
        }
        
        let pickupInput = PickupInput(collectionType: .LOCAL, status: .SUBMITTED, readyDate: Date(), propertyId: "", cartons: cartons, notes: notes)
        
        BackendController.shared.schedulePickup(input: pickupInput) { (error) in
            if let error = error {
                NSLog("\(error): Error scheduling pickup.")
            }
        }
    }
}

extension SchedulePickupViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return cartons.count
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Pickup Details"
        case 1:
            return "Carton Details"
        case 2:
            return "Notes"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            // Select Property
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPropertyCell", for: indexPath) as? PickupPropertyTableViewCell else { return UITableViewCell() }
            
            return cell
        } else if indexPath.section == 0 && indexPath.row == 1 {
            // Select Date
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDateCell", for: indexPath) as? PickupDateTableViewCell else { return UITableViewCell() }
            
            return cell
        } else if indexPath.section == 0 && indexPath.row == 2 {
            // Select Time
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTimeCell", for: indexPath) as? PickupTimeTableViewCell else { return UITableViewCell() }
            
            return cell
        } else if indexPath.section == 1 && indexPath.row == 0 {
            // Add Weight
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickupWeightCell", for: indexPath) as? PickupWeightTableViewCell else { return UITableViewCell() }
            
            return cell
        } else if indexPath.section == 1 && indexPath.row == 1 {
            // Add Cartons
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddPickupCartonCell", for: indexPath) as? AddPickupCartonTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self
            
            return cell
        } else if indexPath.section == 1 && indexPath.row > 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickupCartonCell", for: indexPath) as? PickupCartonTableViewCell else { return UITableViewCell() }

            if cartons[indexPath.row] == 0 {
                // Soap
                cell.iconImageView.image = UIImage(named: "ESB Soap Icon")
                cell.iconImageView.tintColor = UIColor(named: .colorESBGreen)
                cell.cartonTypeLabel.text = "Soap"
                cell.delegate = self
                cell.cellType = .soap
            } else if cartons[indexPath.row] == 1 {
                // Linens
                cell.iconImageView.image = UIImage(named: "ESB Paper Icon")
                cell.iconImageView.tintColor = UIColor(named: .colorESBGreen)
                cell.cartonTypeLabel.text = "Paper"
                cell.delegate = self
                cell.cellType = .paper
            } else if cartons[indexPath.row] == 2 {
                // Paper
                cell.iconImageView.image = UIImage(named: "ESB Linens Icon")
                cell.iconImageView.tintColor = UIColor(named: .colorESBGreen)
                cell.cartonTypeLabel.text = "Linens"
                cell.delegate = self
                cell.cellType = .linens
            } else if cartons[indexPath.row] == 3 {
                // Bottles
                cell.iconImageView.image = UIImage(named: "ESB Bottles Icon")
                cell.iconImageView.tintColor = UIColor(named: .colorESBGreen)
                cell.cartonTypeLabel.text = "Bottles"
                cell.delegate = self
                cell.cellType = .bottles
            }
            
            return cell
        } else if indexPath.section == 2 {
            // Add Notes
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickupNotesCell", for: indexPath) as? PickupNotesTableViewCell else { return UITableViewCell() }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension SchedulePickupViewController: DeselectTableViewCellOnDismissDelegate {
    func deselectTableViewCell() {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            // Clear selected cell when the user returns from selecting a property
            self.tableView.deselectRow(at: selectionIndexPath, animated: false)
        }
    }
}

// Custom cell delegate methods
extension SchedulePickupViewController: AddCartonCellDelegate, UserAddedNotesDelegate, UserAddedPercentageDelegate {
    // PickupCartonTableViewCell
    func userAddedPercentage(for cellIdentifier: UUID, cellType: CartonTypes, percentage: Int) {
        switch cellType {
        case .soap:
            soapCartons[cellIdentifier] = percentage
        case .paper:
            paperCartons[cellIdentifier] = percentage
        case .linens:
            linenCartons[cellIdentifier] = percentage
        case .bottles:
            bottleCartons[cellIdentifier] = percentage
        }
    }
    
    // PickupNotesTableViewCell
    func userAddedNotes(notes: String) {
        self.notes = notes
    }
    
    // AddPickupCartonTableViewCell
    func addCartonCell(for type: Int) {
        cartons.append(type)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
    }
}

