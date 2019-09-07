//Copyright © 2019 Tabcorp. All rights reserved.

import Foundation
import Foundation
import Quick
import Nimble
@testable import Uluru

class ServiceProvderSpec: QuickSpec {
    override func spec() {
        TestHelper.markWaitExpecationAsAPIRequest()
        var service: ServiceProvider<TestAPIDefinition>!

        beforeEach {
            service = ServiceProvider()
        }

        // Custom JSONDecoder
        context("Custom JSONDecoder") {
            var customDecoder: CustomDecoder!
            beforeEach {
                customDecoder = CustomDecoder()
                service = ServiceProvider(jsonDecoder: customDecoder)
            }

            it("uses the provided json decoder") {
                waitUntil { done in
                    let _ = service.request(TestAPIDefinition.justGet) { (result: Result<TestDecodableModel, Error>) in
                        done()
                    }
                }

                expect(customDecoder.isInvoked).to( beTrue() )
            }
        }

        // MARK: Placeholder data
        context("Placeholder data") {
            beforeEach {
                service = ServiceProvider()
            }

            it("should return placeholder data when provided") {
                var decoded: MockPlaceholder!
                waitUntil { done in
                    let _  = service.request(.justGetWithPlaceholderData) { (result: Result<MockPlaceholder, Error>) in
                        decoded = try! result.get()
                        done()
                    }
                }

                expect(decoded).to( equal(MockPlaceholder()) )
            }

            it("statusCode of placeholder data response is 200") {
                var dataSuccessResponse: DataSuccessResponse!
                waitUntil { done in
                    let _ = service.requestData(.justGetWithPlaceholderData) { result in
                        dataSuccessResponse = try! result.get()
                        done()
                    }
                }

                expect(dataSuccessResponse.urlResponse.statusCode).to( equal(200) )
            }
        }

    }
}

