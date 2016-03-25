//
//  DomainTest.swift
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

class AnyEquatable<Value:Equatable> : Equatable {
  let value : Value
  
  init (value: Value) {
    self.value = value
  }
}

func ==<E:Equatable> (lhs:AnyEquatable<E>, rhs:AnyEquatable<E>) -> Bool {
  return lhs.value == rhs.value
}

class Person {
  let name : String
  let ssn  : String
  
  init (name: String, ssn: String) {
    self.name = name
    self.ssn  = ssn
  }

  static func compareByName (p1: Person, p2: Person) -> Bool {
    return p1.name == p2.name
  }
  
  static func compareBySSN(p1: Person, p2: Person) -> Bool {
    return p1.ssn == p2.ssn
  }
}

class DomainTest: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }


  func assertDomainValuesTrue<Value> (_ domain: Domain<Value>, values: Value...) {
    values.forEach { XCTAssertTrue(domain.contains($0)) }
  }
  
  func assertDomainValuesFalse<Value> (_ domain: Domain<Value>, values: Value...) {
    values.forEach { XCTAssertFalse(domain.contains($0)) }
  }
  
  // MARK: Test Always Domain
  
  func testDomainAlways() {
    let alwaysTrue  = AlwaysDomain<Any>(result: true)
    let alwaysFalse = AlwaysDomain<Any>(result: false)
    
    assertDomainValuesTrue  (alwaysTrue,  values: 1, "abc", 0.0, AlwaysDomain<Int>(result: true))
    assertDomainValuesFalse (alwaysFalse, values: 1, "abc", 0.0, AlwaysDomain<Int>(result: true))
  }
  
  // MARK: Test Singleton Domain
  
  func testDomainSingleton () {
    let singletonString = SingletonDomain<String>(value: "domain")
    
    assertDomainValuesTrue  (singletonString, values: "domain", "dom" + "ain")
    assertDomainValuesFalse (singletonString, values: "domain1", "dom" + "2ain", "not this")

    let singletonInt = SingletonDomain<Int>(value: 0)
    
    assertDomainValuesTrue(singletonInt, values: 0, 10 * 0, -10 + 10)
    assertDomainValuesFalse(singletonInt, values: -2, -1, 1, 2)
    
    let singletonEquatable = SingletonDomain(value: AnyEquatable<Int>(value: 0))
    
    assertDomainValuesTrue  (singletonEquatable, values: AnyEquatable<Int>(value: 0 ), AnyEquatable<Int>(value: 0))
    assertDomainValuesFalse (singletonEquatable, values: AnyEquatable<Int>(value: -1), AnyEquatable<Int>(value: 1))
    
    let singletonPersonName = SingletonDomain(value: Person (name: "me", ssn: "123-45-6789"), test: Person.compareByName)
    assertDomainValuesTrue(singletonPersonName,
      values: Person (name: "me", ssn: "000-00-000"),
              Person (name: "me", ssn: "000-00-000"))
    assertDomainValuesFalse(singletonPersonName,
      values: Person (name: "me2", ssn: "123-45-6789"),
              Person (name: "you", ssn: "123-45-6789"))
    
    let singletonPersonSSN = SingletonDomain(value: Person (name: "me", ssn: "123-45-6789"), test: Person.compareBySSN)
    assertDomainValuesFalse(singletonPersonSSN,
      values: Person (name: "me", ssn: "000-00-000"),
              Person (name: "me", ssn: "000-00-000"))
    assertDomainValuesTrue(singletonPersonSSN,
      values: Person (name: "me2", ssn: "123-45-6789"),
              Person (name: "you", ssn: "123-45-6789"))
  }
  
  // MARK: Test Enumerated Domain
  
  func testDomainEnumerated () {
    let enumeratedInts = EnumeratedDomain<Int>(values: 0, 5, 10)
    
    assertDomainValuesTrue  (enumeratedInts, values: 0, 5, 10, 10, 0)
    assertDomainValuesFalse (enumeratedInts, values: 1, 2, 3, 4)
    
    let enumeratedPersonName = EnumeratedDomain(values: [Person(name: "me", ssn: "000-00-000"), Person(name: "you", ssn: "000-00-000")],
                                                test: Person.compareByName)
    
    assertDomainValuesTrue(enumeratedPersonName, values: Person(name: "me", ssn: "123-45-6789"))
  }
  
  // MARK: Test Set Domain
  
  func testDomainSet () {
    let setInts = SetDomain<Int>(set: [0, 5, 10])
    
    assertDomainValuesTrue  (setInts, values: 0, 5, 10)
    assertDomainValuesFalse (setInts, values: -11, -1, 1, 11)
  }
  
  // MARK: Test Range Domain
  
  func testDomainRange () {
    let rangeInts = RangeDomain<Int>(range: ContiguousRange<Int>(minimum: 0, maximum: 5))
    
    assertDomainValuesTrue  (rangeInts, values: 0, 1, 2, 3, 4)
    assertDomainValuesFalse (rangeInts, values: -2, -1, 5)
  }
  
  // MARK: Test Complement Domain
  
  func testDomainComplement () {
    let complementSetInts = ComplementDomain<Int>(domain: SetDomain<Int>(set: [-5, 0, 5]))
    
    assertDomainValuesTrue  (complementSetInts, values: -10, 10)
    assertDomainValuesFalse (complementSetInts, values: -5, 0, 5)
  }

  // MARK: Test Compound Domain
  
  func testDomainCompound () {
    
    let compoundIntOr = CompoundDomain<Int>(logic: .or,
                                            domains: SetDomain<Int>(values: 0, 1, 2),
                                                     SetDomain<Int>(values: 3, 4))
    
    assertDomainValuesTrue  (compoundIntOr, values: 0, 1, 2, 3, 4)
    assertDomainValuesFalse (compoundIntOr, values: 5, 6, 7)

    let compoundIntAnd = CompoundDomain<Int>(logic: .and,
                                             domains: SetDomain<Int>(values: 0, 1, 2, 3),
                                                      SetDomain<Int>(values: 2, 3, 4, 5))
    
    assertDomainValuesTrue  (compoundIntAnd, values: 2, 3)
    assertDomainValuesFalse (compoundIntAnd, values: -1, 0, 1, 4, 5)
}
  
  func testPerformanceExample() {
    self.measure {
    }
  }
}
