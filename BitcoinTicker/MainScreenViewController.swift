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
    @IBOutlet var sparklineView: CKSparkline!

    let priceController = PriceController()


    var loading: Bool = false


    required init(coder: NSCoder) {
        super.init(coder: coder)

        priceController.addPriceUpdatedObserver { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.loading = false
                self.showCurrentPrice(currentPrice: price)
            }
        }

        priceController.addHistoryUpdatedObserver { prices in
            if let prices = prices {
                dispatch_async(dispatch_get_main_queue()) {
                    self.sparklineView.data = prices
                }
            }
        }

        refreshPrice()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sparklineView.lineColor = UIColor(white: 0.0, alpha: 0.75)

        showCurrentPrice()
    }

    func refreshPrice() {
        if !loading {
            loading = true
            priceController.fetchPrice()
        }
    }

    func showCurrentPrice(currentPrice: Float? = nil) {
        priceLabel.text = priceController.formatPrice(currentPrice)
    }

    @IBAction func bitcoinAverageLinkClicked() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://bitcoinaverage.com")!)
    }
}
