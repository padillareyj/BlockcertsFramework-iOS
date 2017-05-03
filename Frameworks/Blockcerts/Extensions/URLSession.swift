//
//  URLSession.swift
//  cert-wallet
//
//  Created by Chris Downie on 9/1/16.
//  Copyright © 2016 Digital Certificates Project. All rights reserved.
//

import Foundation

//
// This is an implementation of the technique described here:
// http://masilotti.com/testing-nsurlsession-input/
//
// The goal is to use protocol-oriented programming to let us inject mock URL Session classes during tests.
// We also need to make sure the existing Foundation classes conform to these protocols as well.
//

/// A common protocol for a URLSession. We can use this to mock out the network during tests
public protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

/// A common protocol for handling URLSessionDataTasks. We can use this to mock out the network during tests.
public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}


extension URLSession : URLSessionProtocol {
    public func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let result : URLSessionDataTask = dataTask(with: url, completionHandler: completionHandler)
        return result as URLSessionDataTaskProtocol
    }
    
    public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        let result : URLSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        return result as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask : URLSessionDataTaskProtocol {}

