//
//  VariableTest.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/26/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import XCTest
import SBUnits
import SBCommons
@testable import SBVariables

class VariableTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  let t1 = Quantity<Time>(value: 0.0, unit: second)

  func testVariable() {
    let v1 = Variable<Double>(name: "ignore", time: t1, value: 1.0, domain: AlwaysDomain(result: true))!
    
    v1.assign(5.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(v1.value, 5.0)
    
    v1.assign(-5.0, time: Quantity<Time>(value: 2.0, unit: second))
    XCTAssertEqual(v1.value, -5.0)
  }

  func testVariableDelegate () {
    let v1 = Variable<Double>(name: "ignore", time: t1, value: 1.0, domain: AlwaysDomain(result: true))!

    var assignedValues = Array<Double>()
    var missedValues = Array<Double>()
    
    let d2 = VariableDelegate<Double>(
      canAssign: { (variable: Variable<Double>, value:Double) -> Bool in
        return value > 0.0
      },
      didAssign: { (variable: Variable<Double>, value:Double) -> () in
        assignedValues.append(value)
        return
      },
      didNotAssign: { (variable: Variable<Double>, value:Double) -> () in
        missedValues.append(value)
        return
    })
    v1.delegate = d2 // value > 0.0
    
    v1.assign(2.0, time: Quantity<Time>(value: 3.0, unit: second))
    XCTAssertEqual(v1.value, 2.0)
    XCTAssertTrue(assignedValues.contains(2.0))
    XCTAssertEqual(0, missedValues.count)
    
    v1.assign(-2.0, time: Quantity<Time>(value: 4.0, unit: second))
    XCTAssertEqual(v1.value, 2.0)
    XCTAssertTrue(assignedValues.contains(2.0))
    XCTAssertTrue(missedValues.contains(-2.0))
  }
  
  func testVariableMonitor () {
    let v1 = Variable<Double>(name: "ignore", time: t1, value: 1.0, domain: AlwaysDomain(result: true))!
    let m1 = OnChangeReportSeriesMonitor<Double>(value: 1.0, changed: !=)
    
    v1.addMonitor(m1)
    
    v1.assign(1.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(1, m1.values.count)
    XCTAssertEqual(1.0, m1.lastValue!)
    
    v1.assign(5.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(2, m1.values.count)
    XCTAssertTrue(m1.values.all({ $0 == 5.0 || $0 == 1.0 }))
  }

  func testVariableHistory () {
    let v1 = Variable<Double>(name: "ignore", time: t1, value: 1.0, domain: AlwaysDomain(result: true))!
    
    v1.history = History<Double>(capacity: 2)
    
    v1.assign(1.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(1, v1.history?.count)
    
    v1.assign(1.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(2, v1.history?.count)

    v1.assign(2.0, time: Quantity<Time>(value: 1.0, unit: second))
    XCTAssertEqual(2, v1.history?.count)
  }

  func testPerformanceExample() {
    self.measure {
    }
  }
}
