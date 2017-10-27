//
//  Logger.swift
//  SportsStore
//
//  Created by Mohammed Rokon Uddin on 26/10/17.
//  Copyright © 2017 Apress. All rights reserved.
//

import Foundation

let productLogger = Logger<Product>(callback: { p in
    print("Change: \(p.name) \(p.stockLevel) items in stock")
})

final class Logger<T> where T: NSObject, T: NSCopying {
    var dataItems: [T] = []
    var callback:(T) -> Void
    var arrayQ = DispatchQueue(label: "queuename", attributes: .concurrent)
     var callbackQ = DispatchQueue(label: "callbackQ")

    fileprivate init(callback:@escaping (T) -> Void, protect: Bool = true) {
        self.callback = callback
        if protect {
            self.callback = { [weak self] item in
                self?.callbackQ.async { [weak self] in
                    self?.callback(item)
                }
            }
        }
    }

    func logItem(item: T) {
        arrayQ.async { [weak self] in
            self?.dataItems.append(item.copy() as! T)
            self?.callback(item)
        }
    }

    func processItems(callback:(T) -> Void) {
        arrayQ.sync { [weak self] in
            for item in dataItems {
                self?.callback(item)
            }
        }
    }
}
