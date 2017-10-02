//
//  ViewController.swift
//  Simple GPS Speedometer
//
//  Created by Antti Vekkeli on 30/09/2017.
//  Copyright © 2017 Antti Vekkeli. All rights reserved.
//

import UIKit

class SpeedViewController: UIViewController {
    
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelAccuracy: UILabel!
    @IBOutlet weak var labelUnits: UILabel!

    private let locationHandler = LocationHandler()
    
    static let keyStyle = "CommonStyle"
    static let keyUnits = "CommonUnits"
    
    enum Style: String {
        case dark
        case light
    }

    enum Units: String {
        case metric
        case imperial
    }

    private var style: Style = .dark
    private var units: Units = .metric
    
    private func readSettings() {
        if let savedStyle = UserDefaults.standard.value(forKey: SpeedViewController.keyStyle) as? String {
            style = Style(rawValue: savedStyle) ?? .dark
        }
        
        if let savedUnits = UserDefaults.standard.value(forKey: SpeedViewController.keyUnits) as? String {
            units = Units(rawValue: savedUnits) ?? .metric
        }
    }
    
    private func saveSettings() {
        
        UserDefaults.standard.set(style.rawValue, forKey: SpeedViewController.keyStyle)
        UserDefaults.standard.set(units.rawValue, forKey: SpeedViewController.keyUnits)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            switchStyle()
        }
    }
    
    @IBAction func doubleTapHandler(_ sender: Any) {
        switchUnits()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readSettings()
        updateView()
        
        locationHandler.setup()
        locationHandler.start()
        locationHandler.didUpdate = { lh in
            self.updateSpeed()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch style {
        case .dark:
            return .lightContent
        case .light:
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    private func updateView() {
        var labelColor = UIColor.white
        var backgroundColor = UIColor.black
        
        switch style {
        case .dark:
            labelColor = .white
            backgroundColor = .black
        case .light:
            labelColor = .black
            backgroundColor = .white
        }
        
        labelAccuracy.textColor = labelColor
        labelSpeed.textColor = labelColor
        labelUnits.textColor = labelColor
        view.backgroundColor = backgroundColor
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        switch units {
        case .metric:
            labelUnits.text = "km/h"
        case .imperial:
            labelUnits.text = "mph"
        }
        
        updateSpeed()
    }
    
    private func updateSpeed() {
        
        let level5 = "●●●●●"
        let level4 = "●●●●○"
        let level3 = "●●●○○"
        let level2 = "●●○○○"
        let level1 = "●○○○○"
        let level0 = "○○○○○"
        
        let accuracy = locationHandler.accuracyMeters ?? Int.max
        
        if accuracy < 10 {
            self.labelAccuracy.text = level5
        }
        else if accuracy < 20 {
            self.labelAccuracy.text = level4
        }
        else if accuracy < 50 {
            self.labelAccuracy.text = level3
        }
        else if accuracy < 100 {
            self.labelAccuracy.text = level2
        }
        else if accuracy < 500 {
            self.labelAccuracy.text = level1
        }
        else {
            self.labelAccuracy.text = level0
        }
        
        switch self.units {
        case .metric:
            self.labelSpeed.text = locationHandler.speedKmh.description
        case .imperial:
            self.labelSpeed.text = locationHandler.speedMph.description
        }
    }
    
    private func switchStyle() {
        switch style {
        case .dark:
            style = .light
        case .light:
            style = .dark
        }
        updateView()
        saveSettings()
    }
    
    private func switchUnits() {
        switch units {
        case .imperial:
            units = .metric
        case .metric:
            units = .imperial
        }
        updateView()
        saveSettings()
    }
}

