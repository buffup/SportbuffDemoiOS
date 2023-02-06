//
//  Date+Unix.swift
//  SportBuff
//
//  Created by Valsamis Elmaliotis on 15/7/22.
//  Copyright © 2022 Buff Up Ltd. All rights reserved.
//

import Foundation

typealias UnixTimestamp = Int

extension Date {

    var unixTimestamp: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970)
    }

    /// Date to Unix timestamp.
    var unixTimestampInMillisecondPrecision: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970 * 1_000) // millisecond precision
    }
}

extension UnixTimestamp {
    /// Unix timestamp to date.
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }

    var dateFromUnixTimestampWithMillisecondPrecision: Date {
        return Date(timeIntervalSince1970: TimeInterval(self / 1_000)) // must take a millisecond-precise Unix timestamp
    }
}
