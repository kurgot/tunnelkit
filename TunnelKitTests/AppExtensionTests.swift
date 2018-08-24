//
//  AppExtensionTests.swift
//  TunnelKitTests
//
//  Created by Davide De Rosa on 10/23/17.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import XCTest
@testable import TunnelKit
import NetworkExtension

class AppExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConfiguration() {
        var builder: TunnelKitProvider.ConfigurationBuilder!
        var cfg: TunnelKitProvider.Configuration!

        let identifier = "com.example.Provider"
        let appGroup = "group.com.algoritmico.TunnelKit"
        let endpoint = TunnelKitProvider.AuthenticatedEndpoint(
            hostname: "example.com",
            username: "foo",
            password: "bar"
        )

        builder = TunnelKitProvider.ConfigurationBuilder(appGroup: appGroup)
        XCTAssertNotNil(builder)

        builder.cipher = .aes128cbc
        builder.digest = .sha256
        builder.ca = Certificate(pem: "abcdef")
        cfg = builder.build()

        let proto = try? cfg.generatedTunnelProtocol(withBundleIdentifier: identifier, endpoint: endpoint)
        XCTAssertNotNil(proto)
        
        XCTAssertEqual(proto?.providerBundleIdentifier, identifier)
        XCTAssertEqual(proto?.serverAddress, endpoint.hostname)
        XCTAssertEqual(proto?.username, endpoint.username)
        XCTAssertEqual(proto?.passwordReference, try? Keychain(group: appGroup).passwordReference(for: endpoint.username))

        if let pc = proto?.providerConfiguration {
            print("\(pc)")
        }
        
        let K = TunnelKitProvider.Configuration.Keys.self
        XCTAssertEqual(proto?.providerConfiguration?[K.appGroup] as? String, cfg.appGroup)
        XCTAssertEqual(proto?.providerConfiguration?[K.cipherAlgorithm] as? String, cfg.cipher.rawValue)
        XCTAssertEqual(proto?.providerConfiguration?[K.digestAlgorithm] as? String, cfg.digest.rawValue)
        XCTAssertEqual(proto?.providerConfiguration?[K.ca] as? String, cfg.ca?.pem)
        XCTAssertEqual(proto?.providerConfiguration?[K.mtu] as? Int, cfg.mtu)
        XCTAssertEqual(proto?.providerConfiguration?[K.renegotiatesAfter] as? Int, cfg.renegotiatesAfterSeconds)
        XCTAssertEqual(proto?.providerConfiguration?[K.debug] as? Bool, cfg.shouldDebug)
        XCTAssertEqual(proto?.providerConfiguration?[K.debugLogKey] as? String, cfg.debugLogKey)
    }
    
    func testDNSResolver() {
        let exp = expectation(description: "DNS")
        DNSResolver.resolve("djsbjhcbjzhbxjnvsd.com", timeout: 1000, queue: DispatchQueue.main) { (addrs, error) in
            defer {
                exp.fulfill()
            }
            guard let addrs = addrs else {
                print("Can't resolve")
                return
            }
            print("\(addrs)")
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}