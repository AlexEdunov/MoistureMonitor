//
//  ViewController.swift
//  MoistureMonitor
//
//  Created by Alex Edunov on 27.12.20.
//

import UIKit

class ViewController: UIViewController {

    private let discovery = Discovery()

    private let valueLabel = UILabel()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let niceGreen = UIColor.init(hex: "#558B2FFF") {
            view.backgroundColor = niceGreen
        }

        valueLabel.font = .boldSystemFont(ofSize: 40)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 0

        statusLabel.font = .boldSystemFont(ofSize: 40)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.text = "Соединяется"

        view.addSubview(valueLabel)
        view.addSubview(statusLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            valueLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        discovery.valueUpdated = { [unowned self] value in
            let valueText: String
            switch value {
            case 0..<45: valueText = "Грунт просох полностью"
            case 45..<60: valueText = "Грунт просох наполовину"
            default: valueText = "Грунт влажный"
            }

            self.valueLabel.text = valueText
        }

        discovery.connectivityStateUpdated = { [unowned self] connected in
            self.valueLabel.isHidden = !connected
            self.statusLabel.isHidden = connected
        }
    }


}

// Has been stolen 😅
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
