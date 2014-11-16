//
//  TodayViewController.swift
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    // TODO: share code with MainScreenViewController

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sparklineView: CKSparkline!

    let priceController = PriceController()

    var priceLoading: Bool = false {
        didSet {
            priceLabel?.textColor = priceLoading ? UIColor(white: 1.0, alpha: 0.75) : UIColor.whiteColor()
        }
    }

    var historyLoading: Bool = false {
        didSet {
            if let view = sparklineView {
                view.lineColor = historyLoading ? UIColor(white: 1.0, alpha: 0.75) : UIColor.whiteColor()
                view.setNeedsDisplay()
            }
        }
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        priceController.addPriceUpdatedObserver { price in
            dispatch_async(dispatch_get_main_queue()) {
                self.priceLoading = false
                self.showCurrentPrice(currentPrice: price)
            }
        }

        priceController.addHistoryUpdatedObserver { prices in
            if let prices = prices {
                dispatch_async(dispatch_get_main_queue()) {
                    self.historyLoading = false
                    self.sparklineView.data = prices
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // update loading state in the UI
        priceLoading = Bool(priceLoading)
        historyLoading = Bool(historyLoading)

        showCurrentPrice()
    }

    func refreshPrice() {
        if !priceLoading {
            priceLoading = true
            priceController.fetchCurrentPrice()
        }

        if !historyLoading {
            historyLoading = true
            priceController.fetchHistory()
        }
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
