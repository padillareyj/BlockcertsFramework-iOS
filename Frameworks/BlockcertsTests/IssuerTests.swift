//
//  IssuerTests.swift
//  cert-wallet
//
//  Created by Chris Downie on 8/25/16.
//  Copyright © 2016 Digital Certificates Project. All rights reserved.
//

import XCTest
@testable import BlockchainCertificates

class IssuerTests: XCTestCase {
    let nameValue = "Name"
    let emailValue = "Email"
    let imageDataValue = ""
    let idValue = "https://example.com/id"
    let urlValue = "https://example.com/url"
    let publicKeyValue = "BadPublicKey"
    let introductionURLValue = "https://example.com/request"
    let issuerKey = KeyRotation(on: Date(timeIntervalSince1970: 0), key: "ISSUER_KEY")
    let revocationKey = KeyRotation(on: Date(timeIntervalSince1970: 0), key: "REVOCATION_KEY")
    
    override func setUp() {
    }

    func testDictionaryConversion() {
        let issuer = Issuer(name: nameValue,
                            email: emailValue,
                            image: Data(),
                            id: URL(string: idValue)!,
                            url: URL(string: urlValue)!,
                            publicIssuerKeys: [issuerKey],
                            publicRevocationKeys: [revocationKey],
                            introductionURL: URL(string: introductionURLValue)!)
        
        let expectedIssuerKeys : [[String: String]] = [
            [
                "date": issuerKey.on.toString(),
                "key": issuerKey.key
            ]
        ]
        let expectedRevocationKeys : [[String: String]] = [
            [
                "date": revocationKey.on.toString(),
                "key": revocationKey.key
            ]
        ]
        
        let result = issuer.toDictionary()
        XCTAssertEqual(result["name"] as! String, nameValue)
        XCTAssertEqual(result["email"] as! String, emailValue)
        XCTAssertEqual(result["image"] as! String, "data:image/png;base64,\(imageDataValue)")
        XCTAssertEqual(result["id"] as! String, idValue)
        XCTAssertEqual(result["url"] as! String, urlValue)
        XCTAssertEqual(result["introductionURL"] as! String, introductionURLValue)
        
        let issuerKeys = result["issuerKeys"] as! [[String: String]]
        XCTAssertEqual(issuerKeys.count, 1)
        XCTAssertEqual(issuerKeys.first!, expectedIssuerKeys.first!)
        
        let revocationKeys = result["revocationKeys"] as! [[String: String]]
        XCTAssertEqual(revocationKeys.count, 1)
        XCTAssertEqual(revocationKeys.first!, expectedRevocationKeys.first!)
    }
    
    func testDictionaryInitialization() {
        let input : [String : Any] = [
            "name": nameValue,
            "email": emailValue,
            "image": "data:image/png;base64,\(imageDataValue)",
            "id": idValue,
            "url": urlValue,
            "publicKey": publicKeyValue,
            "introductionURL": introductionURLValue,
            "issuerKeys": [
                [
                    "date": issuerKey.on.toString(),
                    "key": issuerKey.key
                ]
            ],
            "revocationKeys": [
                [
                    "date": revocationKey.on.toString(),
                    "key": revocationKey.key
                ]
            ]

        ]
        let expectedResult = Issuer(name: nameValue,
                                    email: emailValue,
                                    image: Data(),
                                    id: URL(string: idValue)!,
                                    url: URL(string: urlValue)!,
                                    publicIssuerKeys: [issuerKey],
                                    publicRevocationKeys: [revocationKey],
                                    introductionURL: URL(string: introductionURLValue)!)
        let result = try! Issuer(dictionary: input)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedResult)
    }
}
