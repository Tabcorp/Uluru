//Copyright © 2019 Tabcorp. All rights reserved.

import Foundation
@testable import Uluru

class TestPlugin: ServicePluginType {
    var didMutate: Bool = false
    var didRecieveResponse: Bool = false
    var errorWithLove = NSError(domain: "plugin", code: -1, userInfo: ["animal": "godzilla"])

    func mutate(_ request: URLRequest, target: APIDefinition) -> URLRequest {
        var ourRequest = request
        ourRequest.adding(value: "godzilla", headerField: "animal")
        return ourRequest
    }

    func willSend(_ request: URLRequest, target: APIDefinition) {
        // To ensure we did mutate the request earlier.
        didMutate = (request.value(forHTTPHeaderField: "animal") == "godzilla")
    }

    func didReceive(_ result: DataResult, target: APIDefinition) {
        didRecieveResponse = true
    }

    func willFinish(_ result: DataResult, target: APIDefinition) -> DataResult {
        return .failure(DataErrorResponse(error: errorWithLove, data: nil, urlResponse: nil))
    }
}
