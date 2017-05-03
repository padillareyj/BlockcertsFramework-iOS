//
//  TransactionDataRequest.swift
//  cert-wallet
//
//  Created by Kim Duffy on 8/28/16.
//  Copyright © 2016 Digital Certificates Project. All rights reserved.
//

import Foundation


public struct TransactionData {
    public let opReturnScript : String?
    public let revokedAddresses : Set<String>?
}

public class TransactionDataHandler {
    public let transactionId : String?
    public let transactionUrlAsString : String?
    public var failureReason : String?
    public var transactionData : TransactionData?
    
    public init(transactionId: String, transactionUrlAsString: String) {
        self.transactionId = transactionId
        self.transactionUrlAsString = transactionUrlAsString
    }
    
    public func parseResponse(json: [String : AnyObject]) {
        // TODO: this actually is intended as a abstract method, which means this should be
        // done differently....
    }
    
    public static func create(chain: BitcoinChain, transactionId: String) -> TransactionDataHandler {
        if chain == .testnet {
            return BlockcypherHandler(transactionId: transactionId)
        } else {
            return BlockchainInfoHandler(transactionId: transactionId)
        }
    }
}

public class BlockchainInfoHandler : TransactionDataHandler {
    public init(transactionId: String) {
        super.init(transactionId: transactionId, transactionUrlAsString: "https://blockchain.info/rawtx/\(transactionId)?cors=true")
    }
    
    override public func parseResponse(json: [String : AnyObject]) {
        guard let outputs = json["out"] as? [[String: AnyObject]] else {
            super.failureReason = "Missing 'out' property in response:\n\(json)"
            return
        }
        guard let lastOutput = outputs.last else {
            super.failureReason = "Couldn't find the last 'value' key in outputs: \(outputs)"
            return
        }
        guard let value = lastOutput["value"] as? Int,
            let opReturnScript = lastOutput["script"] as? String else {
                super.failureReason = "Couldn't find the last 'value' key in outputs: \(outputs)"
                return
        }
        guard value == 0 else {
            super.failureReason = "No output values were 0: \(outputs)"
            return
        }
        var revoked : Set<String> = Set()
        for output in outputs {
            if (output["spent"] as? Bool == true) {
                revoked.insert(output["addr"] as! String)
            }
        }
        
        super.transactionData = TransactionData(opReturnScript : opReturnScript, revokedAddresses: revoked)
    }
}

public class BlockcypherHandler : TransactionDataHandler {
    public init(transactionId: String) {
        super.init(transactionId: transactionId, transactionUrlAsString: "http://api.blockcypher.com/v1/btc/test3/txs/\(transactionId)")
    }
    override public func parseResponse(json: [String : AnyObject]) {
        guard let outputs = json["outputs"] as? [[String: AnyObject]] else {
            super.failureReason = "Missing 'out' property in response:\n\(json)"
            return
        }
        guard let lastOutput = outputs.last else {
            super.failureReason = "Couldn't find the last 'value' key in outputs: \(outputs)"
            return
        }
        guard let value = lastOutput["value"] as? Int,
            let opReturnScript = lastOutput["data_hex"] as? String else {
                super.failureReason = "Couldn't find the last 'value' key in outputs: \(outputs)"
                return
        }
        guard value == 0 else {
            super.failureReason = "No output values were 0: \(outputs)"
            return
        }
        var revoked : Set<String> = Set()
        for output in outputs {
            if (output["spent_by"] as? String != nil) {
                let addresses = output["addresses"] as! [String]
                revoked.insert(addresses[0])
            }
        }
        
        super.transactionData = TransactionData(opReturnScript : opReturnScript, revokedAddresses: revoked)
    }
}
