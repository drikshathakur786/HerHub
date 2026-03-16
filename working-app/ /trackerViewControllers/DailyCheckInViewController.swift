//
//  DailyCheckInViewController.swift
//  HerHub
//
//  Created by Dhruv on 10/11/25.
//

import UIKit

class DailyCheckInViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sleepValueLabel: UILabel!
    @IBOutlet weak var sleepSlider: UISlider!
    @IBOutlet weak var stressValueLabel: UILabel!
    @IBOutlet weak var stressSlider: UISlider!
    @IBOutlet weak var periodSwitch: UISwitch!
    @IBOutlet weak var logCheckInButton: UIButton!
    
    // MARK: - Properties
    var onSave: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Dynamic greeting based on time of day
        let hour = Calendar.current.component(.hour, from: Date())
        if let title = titleLabel {
            switch hour {
            case 5..<12:
                title.text = "Good Morning ☀️"
            case 12..<17:
                title.text = "Good Afternoon 🌤️"
            case 17..<21:
                title.text = "Good Evening 🌅"
            default:
                title.text = "Good Night 🌙"
            }
        }
        
        // Date
        if let dateLbl = dateLabel {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            dateLbl.text = formatter.string(from: Date())
        }
        
        // Button style
        if let btn = logCheckInButton {
            btn.layer.cornerRadius = 25
            btn.layer.cornerCurve = .continuous
            
            // Shadow
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 4)
            btn.layer.shadowRadius = 8
            btn.layer.shadowOpacity = 0.2
        }
    }
    
    private func setupActions() {
        // Initial values
        if let sleepSldr = sleepSlider {
            sleepChanged(sleepSldr)
        }
        if let stressSldr = stressSlider {
            stressChanged(stressSldr)
        }
    }
    
    // MARK: - IBActions
    @IBAction func sleepChanged(_ sender: UISlider) {
        // Snap to 0.5 increments
        let step: Float = 0.5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        if let lbl = sleepValueLabel {
            lbl.text = "\(String(format: "%.1f", roundedValue)) hrs"
        }
    }
    
    @IBAction func stressChanged(_ sender: UISlider) {
        let value = Int(round(sender.value))
        sender.value = Float(value)
        if let lbl = stressValueLabel {
            lbl.text = "\(value) / 10"
            
            switch value {
            case 1...3:
                lbl.textColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1) // Green
                sliderColor(UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1))
            case 4...7:
                lbl.textColor = .systemOrange
                sliderColor(.systemOrange)
            case 8...10:
                lbl.textColor = .systemRed
                sliderColor(.systemRed)
            default: break
            }
        }
    }
    
    private func sliderColor(_ color: UIColor) {
        stressSlider?.minimumTrackTintColor = color
        stressSlider?.thumbTintColor = color
    }
    
    @IBAction func logCheckInTapped(_ sender: UIButton) {
        if AuthManager.shared.currentUser?.isGuest == true {
            self.showGuestLoginPrompt()
            return
        }

        guard let currentUser = AuthManager.shared.currentUser else { return }
        
        let sleep = Double(sleepSlider?.value ?? 7.0)
        let stress = Int(stressSlider?.value ?? 5)
        let didStartParams = periodSwitch?.isOn ?? false
        
        // Create Check-In Object
        let checkIn = CycleCheckIn(
            id: UUID(),
            user_id: currentUser.id,
            date: Date(),
            symptomsPresent: false, // Default for now
            currentStress: stress,
            sleepHours: sleep,
            sickOrMeds: false,
            exerciseChange: .same,
            periodStartedToday: didStartParams
        )
        
        // Save Logic
        Task {
            do {
                try await CycleDataController.shared.saveCheckIn(checkIn, forUser: currentUser.id)
                print(" [DailyCheckIn] Saved successfully")
                
                await MainActor.run {
                    self.onSave?() // Clean callback
                    self.dismiss(animated: true)
                }
            } catch {
                print(" [DailyCheckIn] Error saving: \(error)")
            }
        }
    }
}

