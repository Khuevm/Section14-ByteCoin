//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinData: CoinData)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "8692F062-5EFD-47C7-9CCE-DA92F0A7AE3F"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    func getCoinPrice(currency: String){
        let coinURL = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: coinURL)
    }
    
    func performRequest(with coinUrl: String) {
        if let url = URL(string: coinUrl){
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let coinData = parseJSON(safeData) {
                        delegate?.didUpdateCoin(coinData)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ coinData: Data) -> CoinData? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let currency = decodedData.asset_id_quote
            let price = decodedData.rate
            
            let coin = CoinData(asset_id_quote: currency, rate: price)
            return coin
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
