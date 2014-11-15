//
//  MainScreenViewController.swift
//  BitcoinTicker
//
//  Created by Jakub Suder on 15/11/14.
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {

    @IBOutlet var priceLabel: UILabel!

    let priceController = PriceController()
    let formatter: NSNumberFormatter

    required init(coder: NSCoder) {
        formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showCurrentPrice()
    }

    func showCurrentPrice() {
        if let price = priceController.currentPrice {
            priceLabel.text = formatter.stringFromNumber(price)
        } else {
            priceLabel.text = "?"
        }
    }

    @IBAction func bitcoinAverageLinkClicked() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://bitcoinaverage.com")!)
    }
}
