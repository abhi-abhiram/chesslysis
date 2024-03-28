//
//  Array+Add.swift
//  DoubleConversion
//
//  Created by Anukoola abhiram on 28/03/24.
//

import Foundation

extension Array where Element == Float {
    func add(_ arr: [Float]) -> [Float] {
        zip(self, arr).map(+) + (self.count < arr.count ? arr[self.count ..< arr.count] : self[arr.count ..< self.count])
    }
}
