//
//  Promise.swift
//  FullPromiseLib
//
//  Created by Gregory Maksyuk on 11/27/17.
//  Copyright © 2017 Gregory Maksyuk. All rights reserved.
//

import Foundation


enum PromiseState<V, E> {
    case idle
    case fulfilled(V)
    case failed(E)
}


class Promise<V, E> {
    
//    private var state: PromiseState<V, E> = .idle
    
    private var valueBlock: ((V) -> Void)?
    private var failureBlock: ((E) -> Void)?
    
    /// Executes piece of code without taking
    @discardableResult func next(_ block: @escaping (V) -> Void) -> Promise<V, E> {
        let subPromise = Promise<V, E>()
        valueBlock = { value in
            block(value)
            subPromise.fulfill(with: value)
        }
        failureBlock = subPromise.reject
        return subPromise
    }
    
    /// Executes piece of code with converting Value to another type
    func next<VV>(_ block: @escaping (V) -> VV) -> Promise<VV, E> {
        let subPromise = Promise<VV, E>()
        valueBlock = { value in
            subPromise.fulfill(with: block(value))
        }
        failureBlock = subPromise.reject
        return subPromise
    }
    
    /// Executes on error and is a stopper
    @discardableResult func onError(_ block: @escaping (E) -> Void) -> Promise<V, E> {
        let subPromise = Promise<V, E>()
        failureBlock = { error in
            block(error)
            subPromise.reject(with: error)
        }
        return subPromise
    }
    
    /// Converts error to another type
    func mapError<EE>(_ block: @escaping (E) -> EE) -> Promise<V, EE> {
        let subPromise = Promise<V, EE>()
        failureBlock = { error in
            subPromise.reject(with: block(error))
        }
        return subPromise
    }
    
    func fulfill(with value: V) {
        valueBlock?(value)
    }
    
    func reject(with error: E) {
        failureBlock?(error)
    }
    
}
