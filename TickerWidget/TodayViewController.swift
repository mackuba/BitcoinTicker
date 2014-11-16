//
//  TodayViewController.swift
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sparklineView: CKSparkline!

    let priceController = PriceController()

    required init(coder: NSCoder) {
        super.init(coder: coder)

        priceController.addPriceUpdatedObserver { price in
            dispatch_async(dispatch_get_main_queue()) {
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
