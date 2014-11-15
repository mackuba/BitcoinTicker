//
//  TodayViewController.swift
//  TickerWidget
//
//  Created by Jakub Suder on 15/11/14.
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var priceLabel: UILabel!

    let priceController = PriceController()

    required init(coder: NSCoder) {
        super.init(coder: coder)

        priceController.addPriceUpdatedObserver { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.showCurrentPrice(currentPrice: price)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        showCurrentPrice()
    }

    func refreshPrice() {
        priceController.fetchPrice()
    }

    func showCurrentPrice(currentPrice: Float? = nil) {
        priceLabel.text = priceController.formatPrice(currentPrice)
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        refreshPrice()

        // TODO:
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
}
