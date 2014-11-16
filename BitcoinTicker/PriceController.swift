//
//  PriceController.swift
//  Copyright (c) 2014 Jakub Suder. All rights reserved.
//

class PriceController {
    var currentPrice: Float?
    var priceHistory: [Float]?

    var priceUpdatedObservers: [(Float?) -> ()]
    var historyUpdatedObservers: [([Float]?) -> ()]

    let net = Net(baseUrlString: "https://api.bitcoinaverage.com")

    lazy var priceFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencySymbol = "$"
        return formatter
    }()

    lazy var csvPriceFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        return formatter
    }()

    init() {
        priceUpdatedObservers = []
        historyUpdatedObservers = []
    }

    func fetchPrice() {
        fetchCurrentPrice()
        fetchHistory()
    }

    func fetchCurrentPrice() {
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

    func fetchHistory() {
        net.GET("/history/USD/per_minute_24h_sliding_window.csv",
            params: nil,
            successHandler: { responseData in
                let priceHistory = self.parseHistoryFromResponse(responseData)

                if priceHistory != nil {
                    self.priceHistory = priceHistory
                }

                self.historyUpdatedObservers.map { observer in observer(priceHistory) }
            },
            failureHandler: { error in
                NSLog("Error: Couldn't fetch price history: %@", error)

                self.historyUpdatedObservers.map { observer in observer(nil) }
            })
    }

    func addPriceUpdatedObserver(callback: (Float?) -> ()) {
        priceUpdatedObservers.append(callback)
    }

    func addHistoryUpdatedObserver(callback: ([Float]?) -> ()) {
        historyUpdatedObservers.append(callback)
    }

    func formatPrice(priceToDisplay: Float?) -> String {
        if let price = priceToDisplay ?? currentPrice {
            return priceFormatter.stringFromNumber(price) ?? "?"
        } else {
            return "?"
        }
    }

    private func parsePriceFromResponse(response: ResponseData) -> Float? {
        let json = self.parseJSONFromResponse(response)
        return json?["last"] as? Float
    }

    private func parseHistoryFromResponse(response: ResponseData) -> [Float]? {
        let data = parseCSVFromResponse(response, skipHeaders: true)

        return data?.map { record in
            if let number = self.csvPriceFormatter.numberFromString(record[1]) {
                return number.floatValue
            } else {
                return 0.0
            }
        }
    }

    private func parseJSONFromResponse(response: ResponseData) -> NSDictionary? {
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

    private func parseCSVFromResponse(response: ResponseData, skipHeaders: Bool = false) -> [[NSString]]? {
        let text = NSString(data: response.data, encoding: NSUTF8StringEncoding)

        if text == nil {
            NSLog("Error: Couldn't parse response - incorrect text encoding")
            return nil
        }

        let lines = text!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [NSString]
        let dataLines = skipHeaders ? Array(lines[1..<lines.count]) : lines
        let filteredLines = dataLines.filter { line in line.length > 0 }

        return filteredLines.map { line in line.componentsSeparatedByString(",") as [NSString] }
    }
}
