//
//  FetchStatus.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation

/// An enumeration representing the different fetching states of data
enum FetchStatus<T> {
    /// Indicates the fetch is in pending state, waiting to be triggered
    case pending

    /// Indicates the fetch is currently loading data
    case loading

    /// Indicates the fetch has finished with a `Result` value specifying either the fetched data or error occurred
    case finished(Result<T, Error>)
}
