//
//  Item.swift
//  onlybody
//
//  Created by Illia Khvost on 01/05/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
