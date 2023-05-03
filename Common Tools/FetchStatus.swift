//
//  FetchStatus.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation

enum FetchStatus<T> {
    case loading
    case finished(Result<T, Error>)
}
