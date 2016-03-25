//
//  RangeTest.swift
//  SBVariables
//
//  Created by Ed Gamble on 11/17/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
@testable import SBVariables

class RangeTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func assertRangeValuesTrue<Value> (_ range: SBVariables.Range<Value>, values: Value...) {
    values.forEach { XCTAssertTrue(range.contains($0)) }
  }
  
  func assertRangeValuesFalse<Value> (_ range: SBVariables.Range<Value>, values: Value...) {
    values.forEach { XCTAssertFalse(range.contains($0)) }
  }
  
  func testRange () {
    let range1 = ContiguousRange<Double>(minimum: 0.0, maximum: 1.0)

    XCTAssertTrue(range1.incMinimum)
    XCTAssertFalse(range1.incMaximum)
    
    XCTAssertEqual(0.0, range1.minimum)
    XCTAssertEqual(1.0, range1.maximum)
    
    
    assertRangeValuesTrue(range1, values: 0.0, 0.1, 0.5, 0.9999999)
    assertRangeValuesFalse(range1, values: -0.0000001, 1.0, 1.5)
  }

  func testRangeShadow () {
    let range1 = ContiguousRange<Double>(minimum: 0.0, maximum: 1.0)
    let range2 = ContiguousRange<Double>(minimum: 0.1, maximum: 0.9)

    XCTAssertTrue  (range1.shadows(range2) ?? false)
    XCTAssertFalse (range2.shadows(range1) ?? true)
  }
  
  func testRangeBound () {
    XCTAssertEqual(0.0, ContiguousRange.lowerBound(0.0, 1.0))
    XCTAssertEqual(0.0, ContiguousRange.lowerBound(1.0, 0.0))
    XCTAssertEqual(nil, ContiguousRange.lowerBound(0.0, nil))

    XCTAssertEqual(1.0, ContiguousRange.upperBound(0.0, 1.0))
    XCTAssertEqual(1.0, ContiguousRange.upperBound(1.0, 0.0))
    XCTAssertEqual(nil, ContiguousRange.upperBound(0.0, nil))
  }
  
  func testRangeIntersection () {
    let range1 = ContiguousRange<Double>(minimum: 0.0, maximum: 0.6)
    let range2 = ContiguousRange<Double>(minimum: 0.4, maximum: 1.0)

    let range = range1.intersection (range2)
    
    assertRangeValuesTrue  (range, values: 0.4, 0.40001, 0.5, 0.59999)
    assertRangeValuesFalse (range, values: 0.3, 0.39999, 0.6, 0.600001)
  }
  
  func testRangeIntersectionNull () {
    let range1 = ContiguousRange<Double>(minimum: 0.0, maximum: 0.4)
    let range2 = ContiguousRange<Double>(minimum: 0.6, maximum: 1.0)
    
    let range = range1.intersection (range2)
    
    assertRangeValuesFalse(range, values: 0.0, 0.4, 0.5, 0.6, 1.0)
  }
  
  func testRangeIntersectionNilMinimum () {
    let range1 = ContiguousRange<Double>(maximum: 0.4)
    let range2 = ContiguousRange<Double>(minimum: 0.0, maximum: 1.0)
    
    let range = range1.intersection (range2)
    
    assertRangeValuesTrue  (range, values: -0.1, 0.0, 0.1, 0.2, 0.3)
    assertRangeValuesFalse (range, values:  0.4, 0.5, 0.6, 1.0, 2.0)
  }

  func testRangeIntersectionShadow () {
    let range1 = ContiguousRange<Double>(minimum: 0.0, maximum: 1.0)
    let range2 = ContiguousRange<Double>(minimum: 0.1, maximum: 0.9, incMaximum: true)
    
    let range = range1.intersection(range2)

    assertRangeValuesTrue  (range, values:  0.1, 0.5, 0.9)
    assertRangeValuesFalse (range, values:  0.0, 1.0)
  }
  

  func testPerformanceExample() {
    self.measure {
    }
  }
}
