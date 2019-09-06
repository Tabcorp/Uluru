//  Copyright © 2019 Tabcorp. All rights reserved.

import Foundation

public class ServiceProvider: Service {

    // Maps an APIDefinition to a resolved Definition
    public typealias APIDefinitionResolver = (_ apiDefinition: APIDefinition) -> APITarget

    // Maps a resolved definition to an URLRequest
    public typealias RequestMapper = (_ resolvedAPIDefinition: APITarget) -> Result<URLRequest, Error>

    public let apiDefinitionResolver: APIDefinitionResolver

    public let requestMapper: RequestMapper

    public let plugins: [ServicePluginType]

    private let serviceExecutor: ServiceExecutable

    public init(apiDefinitionResolver: @escaping APIDefinitionResolver = ServiceProvider.defaultAPIDefinitionResolver,
                requestMapper: @escaping RequestMapper = ServiceProvider.defaultRequestMapper(),
                plugins: [ServicePluginType] = [],
                serviceExecutor: ServiceExecutable = ExecutorURLSession.make()) {
        self.apiDefinitionResolver = apiDefinitionResolver
        self.requestMapper = requestMapper
        self.serviceExecutor = serviceExecutor
        self.plugins = plugins
    }

    public func request<T>(_ apiDefinition: APIDefinition,
                           completion: @escaping (Result<T, Error>) -> Void) -> ServiceCancellable where T : Decodable {
        return self.perform(apiDefinition) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case let .success(successResponse):
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    completion(self.decode(successResponse.data, using: JSONDecoder()))
                }
                break
            case let .failure(errorResponse):
                completion(.failure(errorResponse.error))
                break
            }
        }
    }

    public func perform(_ apiDefinition: APIDefinition,
                        completion: @escaping ResponseCompletion) -> ServiceCancellable {
        let target = apiDefinitionResolver(apiDefinition)
        switch requestMapper(target) {
        case let .success(urlRequest):
            return perform(urlRequest: urlRequest, target: apiDefinition, completion: completion)
        case let .failure(error):
            completion(.failure(RawErrorResponse(error: error, data: nil, urlResponse: nil)))
            return DummyCancellable()
        }
    }


    private func perform(urlRequest: URLRequest,
                         target: APIDefinition,
                         completion: @escaping ResponseCompletion) -> ServiceCancellable {
        // Let plugins mutate request
        let mutatedResult = plugins.reduce(urlRequest) { $1.mutate($0, target: target) }

        // Invoke plugins to inform we are about to send the request to executor.
        self.plugins.forEach { $0.willSend(mutatedResult, target: target) }

        let postRequestPlugins = plugins
        let onRequestCompletion: ServiceExecutionDataTaskCompletion = { (data, urlResponse, error) in
            let responseResult = self.process(data: data, urlResponse: urlResponse, error: error)

            // Invoke plugins to inform we did receive result.
            //postRequestPlugins.forEach { $0.didReceive(ourResult, target: target) }

            // Invoke plugins to mutate result.
            // let mutatedResult = postRequestPlugins.reduce(ourResult) { $1.willFinish($0, target: target) }

            // Invoke completion
            completion(responseResult)
        }

        // Execute request
        return serviceExecutor.execute(dataRequest: mutatedResult, completion: onRequestCompletion)
    }

    private func process(data: Data?, urlResponse: HTTPURLResponse?, error: Error?) -> ResponseResult {
        switch (urlResponse, data, error) {

            // All good
            case let (.some(urlResponse), data, .none):
                return .success(RawSuccessResponse(data: data ?? Data(), urlResponse: urlResponse))

            // Errored out but with some data.
            case let (.some(urlResponse), data, .some(error)):
                return .failure(RawErrorResponse(error: error, data: data, urlResponse: urlResponse))

            // Error without data
            case let (_, _, .some(error)):
                return .failure(RawErrorResponse(error: error, data: nil, urlResponse: nil))

            // Something wierd so falling back to nsurlerror.
            default:
                return .failure(RawErrorResponse(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), data: nil, urlResponse: nil))
        }
    }

    private func decode<T: Decodable>(_ data: Data, using: JSONDecoder) -> Result<T, Error> {
        do {
            let decoded: T = try JSONDecoder().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(error)
        }
    }
}

struct DummyCancellable: ServiceCancellable {
    let isCancelled: Bool = false
    func cancel() {}
}

