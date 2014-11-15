//
//  PriceController.swift
//  BitcoinTicker
//
//  Created by Jakub Suder on 15/11/14.
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

import UIKit

class PriceController : NSObject {
    var currentPrice: Float?
    var priceUpdatedObservers: [(Float?) -> ()]
    let net = Net(baseUrlString: "https://api.bitcoinaverage.com")

    override init() {
        priceUpdatedObservers = []
    }

    func fetchPrice() {
        net.GET("/ticker/USD",
            params: nil,
            successHandler: { responseData in
                let price = self.parsePriceFromResponse(responseData)

                if price != nil {
                    self.currentPrice = price
                }

                self.priceUpdatedObservers.map { observer in observer(price) }
            },
            failureHandler: { error in
                NSLog("Error: Couldn't fetch current price: %@", error)

                self.priceUpdatedObservers.map { observer in observer(nil) }
            })
    }

    func addPriceUpdatedObserver(callback: (Float?) -> ()) {
        priceUpdatedObservers.append(callback)
    }

    private func parsePriceFromResponse(response: ResponseData) -> Float? {
        if let json = self.parseResponse(response) {
            return json["last"] as? Float
        } else {
            return nil
        }
    }

    private func parseResponse(response: ResponseData) -> NSDictionary? {
        var error: NSError?

        let jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(response.data,
            options: nil, error: &error)

        if let json = jsonData as? NSDictionary {
            return json
        } else {
            NSLog("Error: Couldn't parse JSON: %@", error ?? "unknown problem")
            return nil
        }
    }
}
