//  Copyright © 2019 Tabcorp. All rights reserved.

import Foundation

/// Represents a data response.
public struct DataResponse {
    public let data: Data
    public let request: URLRequest
    public let urlResponse: HTTPURLResponse?

    public init(data: Data, request: URLRequest, urlResponse: HTTPURLResponse?) {
        self.data = data
        self.request = request
        self.urlResponse = urlResponse
    }
}

// Raw Data Requests
public typealias DataResult = Result<DataResponse, ServiceError>
public typealias DataRequestCompletion = (_ completion: DataResult) -> Void

/// Represents a parsed data request.
public struct ParsedDataResponse<T: Decodable> {
    public let parsed: T
    public let dataResponse: DataResponse
}

// Parsed requests
public typealias ParsedDataResponseResult<T: Decodable> = Result<ParsedDataResponse<T>, ServiceError>
public typealias APIRequestCompletion<T: Decodable> = (_ result: Result<ParsedDataResponse<T>, ServiceError>) -> Void

public protocol Service {
    associatedtype API: APIDefinition

    func request<T: Decodable>(_ api: API,
                               expecting: T.Type,
                               completion: @escaping APIRequestCompletion<T>) -> ServiceCancellable
}


