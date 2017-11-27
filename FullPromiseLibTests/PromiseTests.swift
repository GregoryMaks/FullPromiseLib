//
//  PromiseTests.swift
//  FullPromiseLibTests
//
//  Created by Gregory Maksyuk on 11/27/17.
//  Copyright © 2017 Gregory Maksyuk. All rights reserved.
//

import XCTest
@testable import FullPromiseLib


class PromiseTests: XCTestCase {

    let asyncOperationTime = 0.1
    let defaultExpectationWaitTime = 0.3
    
    enum OperationError: Error {
        case some1
        case some2
        case unknown
    }
    
    enum MappedOperationError: Error {
        case mappedSome
        case mappedUnknown
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleNextExecutesOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        
        runSomeAsyncOperationSuccessfully().next { result in
            XCTAssertEqual(result, "10")
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testSimpleNextWontExecuteOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        expect.isInverted = true
        
        runSomeAsyncOperationAndFail().next { result in
            XCTFail("Next should not execute on failure")
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }

    func testMappingNextExecutesAndMapsOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        
        runSomeAsyncOperationSuccessfully()
            .next { result in
                return Int(result)!
            }
            .next { result in
                XCTAssertEqual(result, 10)
                expect.fulfill()
            }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testMappingNextNeverExecutesOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        expect.isInverted = true
        
        _ = runSomeAsyncOperationAndFail()
            .next { result -> Int in
                XCTFail("Next should not execute on failure")
                expect.fulfill()
                return Int(result)!
            }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testOnErrorExecutesOnError() {
        let expect = expectation(description: "Async operation executes")
        
        runSomeAsyncOperationAndFail().onError { error in
            XCTAssertEqual(error, OperationError.some1)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testOnErrorNeverExecutesOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        expect.isInverted = true
        
        runSomeAsyncOperationSuccessfully().onError { error in
            XCTFail("OnError should not execute on success")
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testConvertErrorExecutesAndConvertsOnError() {
        let expect = expectation(description: "Async operation executes")
        
        runSomeAsyncOperationAndFail()
            .mapError { error -> MappedOperationError in
                switch error {
                case .some1, .some2: return .mappedSome
                case .unknown: return .mappedUnknown
                }
            }
            .onError { error in
                XCTAssertEqual(error, MappedOperationError.mappedSome)
                expect.fulfill()
            }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    func testConvertErrorNeverExecutesOnSuccess() {
        let expect = expectation(description: "Async operation executes")
        expect.isInverted = true
        
        _ = runSomeAsyncOperationSuccessfully()
            .mapError { error -> MappedOperationError in
                XCTFail("MapError should not execute on success")
                expect.fulfill()
                return .mappedUnknown
            }
        
        wait(for: [expect], timeout: defaultExpectationWaitTime)
    }
    
    // MARK: Private methods
    
    private func runSomeAsyncOperationSuccessfully() -> Promise<String, OperationError> {
        let promise = Promise<String, OperationError>()
        DispatchQueue.main.asyncAfter(deadline: .now() + asyncOperationTime) {
            promise.fulfill(with: "10")
        }
        return promise
    }
    
    private func runSomeAsyncOperationAndFail() -> Promise<String, OperationError> {
        let promise = Promise<String, OperationError>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            promise.reject(with: OperationError.some1)
        }
        return promise
    }
    
}
