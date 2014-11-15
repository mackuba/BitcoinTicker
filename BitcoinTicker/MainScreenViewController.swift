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

    let formatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"
        return formatter
    }()

    var loading: Bool = false


    required init(coder: NSCoder) {
        super.init(coder: coder)

        priceController.addPriceUpdatedObserver { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.loading = false
                self.showCurrentPrice(currentPrice: price)
            }
        }

        refreshPrice()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showCurrentPrice()
    }

    func refreshPrice() {
        if !loading {
            loading = true
            priceController.fetchPrice()
        }
    }

    func showCurrentPrice(currentPrice: Float? = nil) {
        if let price = currentPrice ?? priceController.currentPrice {
            priceLabel.text = formatter.stringFromNumber(price)
        } else {
            priceLabel.text = "?"
        }
    }

    @IBAction func bitcoinAverageLinkClicked() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://bitcoinaverage.com")!)
    }
}
