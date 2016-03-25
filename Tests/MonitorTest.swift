//
//  MonitorTest.swift
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

class OnChangeReportSeriesMonitor<Value:Equatable> : OnChangeMonitor<Value> {
  var values = Array<Value>()
  
  override func report(_ value: Value) {
    values.append(value)
  }
  
  init (value: Value, changed: @escaping ((Value, Value) -> Bool)) {
    super.init(value: value, changed: changed)
    values.append(value)
  }
}

class MonitorTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func assertMonitorReportTrue<Value> (_ monitor: Monitor<Value>, values: Value...) {
    values.forEach { XCTAssertTrue (monitor.isReportable ($0)) }
  }
  func assertMonitorReportFalse<Value> (_ monitor: Monitor<Value>, values: Value...) {
    values.forEach { XCTAssertFalse (monitor.isReportable ($0)) }
  }
  
  func testMonitorOnChange() {
    let changeInt = OnChangeMonitor<Int>(value: 0)

    assertMonitorReportTrue  (changeInt, values: -1, 1)
    assertMonitorReportFalse (changeInt, values: 0)
  
    changeInt.update(1)
    
    assertMonitorReportTrue  (changeInt, values: -1, 0)
    assertMonitorReportFalse (changeInt, values: 1)
  }
  
  func testMonitorDomain () {
    let monitorDomainInt = DomainMonitor<Int>(domain: EnumeratedDomain<Int>(values: -1, 0, 1))
    
    assertMonitorReportTrue(monitorDomainInt, values: -1, 1)
    assertMonitorReportFalse(monitorDomainInt, values: -2, 2)
  }
  
  func testMonitorPersistent () {
    let monitorPersistentInt = PersistenceDomainMonitor<Int>(limit: 2, domain: SetDomain<Int>(set: Set<Int>(arrayLiteral: 0, 1, 2)))
    
    assertMonitorReportFalse(monitorPersistentInt, values: 0, 1, 2)
    monitorPersistentInt.update(0) //   ; 1
    assertMonitorReportFalse(monitorPersistentInt, values: 0, 1, 2)
    monitorPersistentInt.update(1) //   ; 2
    assertMonitorReportTrue(monitorPersistentInt, values: 0, 1, 2)
    monitorPersistentInt.update(1) //   ; 3
    assertMonitorReportTrue(monitorPersistentInt, values: 0, 1, 2)
  }
  
  func testMonitorObject () {
    let monitorObjectInt = MonitoredObject<Int>()
    let changeInt = OnChangeReportSeriesMonitor<Int>(value: 0, changed: !=)
    let persistInt = PersistenceDomainMonitor<Int>(limit: 2, domain: SetDomain<Int>(set: Set<Int>(arrayLiteral: 0, 1, 2)))

    XCTAssertTrue (monitorObjectInt.acceptsMonitor(changeInt))

    monitorObjectInt.addMonitor(changeInt)
    monitorObjectInt.addMonitor(persistInt)
    XCTAssertEqual(2, monitorObjectInt.monitors.count)
    
    monitorObjectInt.remMonitor(persistInt)
    XCTAssertEqual(1, monitorObjectInt.monitors.count)
    XCTAssertTrue(monitorObjectInt.hasMonitor(changeInt))
    XCTAssertFalse(monitorObjectInt.hasMonitor(persistInt))
    XCTAssertEqual(1, changeInt.values.count)
    
    monitorObjectInt.updateMonitorsFor(1)
    XCTAssertEqual(1, changeInt.lastValue!)
    XCTAssertTrue(changeInt.values.contains(1))
    
    monitorObjectInt.updateMonitorsFor(10)
    XCTAssertEqual(10, changeInt.lastValue!)
    XCTAssertTrue(changeInt.values.contains(1))
    XCTAssertTrue(changeInt.values.contains(10))
    
    monitorObjectInt.updateMonitorsFor(10)
    monitorObjectInt.updateMonitorsFor(10)
    monitorObjectInt.updateMonitorsFor(10)
    XCTAssertEqual(3, changeInt.values.count)
  }
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}
