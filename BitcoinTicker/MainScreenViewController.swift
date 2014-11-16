//
//  MainScreenViewController.swift
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

class MainScreenViewController: UIViewController {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sparklineView: CKSparkline!

    let priceController = PriceController()

    var priceLoading: Bool = false {
        didSet {
            priceLabel?.textColor = priceLoading ? UIColor.grayColor() : UIColor.blackColor()
        }
    }

    var historyLoading: Bool = false {
        didSet {
            if let view = sparklineView {
                view.lineColor = historyLoading ? UIColor(white: 0.0, alpha: 0.5) : UIColor(white: 0.0, alpha: 0.75)
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

    @IBAction func bitcoinAverageLinkClicked() {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://bitcoinaverage.com")!)
    }
}
