//Copyright © 2019 Tabcorp. All rights reserved.

import Foundation
import Quick
import Nimble
@testable import Uluru
@testable import Uluru

class HALAPITargetSpec: QuickSpec {
    override func spec() {
        TestHelper.markWaitExpecationAsAPIRequest()
        var discovery: ServiceDiscoveryType!

        beforeSuite {
            waitUntil() { done in
                discovery = ServiceDiscovery.createInstance(apiRootURL: .localDiscoveryURL)
                done()
            }
        }

        context("HAL Target Resolver") {
            it("should resolve url as expected") {
                let closure = ServiceRequester<SampleHALAPI>.makeHALTargetResolver(discovery)
                let result = closure(.fooBar(promoGroup: PromoGroup(promoGroupId: "12345")))
                let apiTarget = try! result.get()
                let expectedURL = URL(string: "https://uat02.beta.tab.com.au/v1/invenue-service/promo-groups/12345")!
                expect(apiTarget.url).to(equal( expectedURL ))
            }
        }
    }
}

struct PromoGroup: Codable, JSONRepresentable {
    let promoGroupId: String
}

enum SampleHALAPI {
    case fooBar(promoGroup: JSONRepresentable)
}

// Using this enitity "invenue:promo-groups:update":"https://api.beta.tab.com.au/v1/invenue-service/promo-groups/{promoGroupId}",
extension SampleHALAPI: HALAPIDefinition, RequiresHALEntityResolution {

    var entityResolution: EntityResolution {
        switch self {
        case .fooBar(let promoGroup):
            return .namedEntity(.init(name: "invenue:promo-groups:update", variables: promoGroup))
        }
    }

    var method: HTTPMethod {
        return .GET
    }

    var encoding: EncodingStrategy {
        return .dontEncode
    }
}
