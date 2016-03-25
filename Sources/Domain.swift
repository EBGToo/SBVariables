//
//  Domain.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBBasics

///
public class Domain<Value> {
  public func contains (_ value:Value) -> Bool {
    return true
  }
}

// MARK: Always Domain

///
/// An `AlwaysDomain` is a `Domain` that, ignoring object, is either always `true` or always `false`
///
public final class AlwaysDomain<Value> : Domain<Value> {
  
  /// The fixed result of `contains()`
  let result : Bool

  /// Ignores value and returns `result`
  public override func contains (_ value: Value) -> Bool {
    return result
  }

  ///
  /// Initialize an instance
  ///
  /// - parameter result: The fixed result to use
  ///
  public init (result: Bool) {
    self.result = result;
  }
}

// MARK: Singleton Domain

///
/// A `SingletonDomain` is a Domain with a single value in the domain matched with a `test` function.
///
public final class SingletonDomain<Value> : Domain<Value> {

  /// The single value
  let value : Value
  
  /// The comparison predicate
  let test : (Value, Value) -> Bool
  
  public override func contains (_ value: Value) -> Bool {
    return test (value, self.value)
  }
  
  public init (value: Value, test: @escaping (Value, Value) -> Bool) {
    self.value = value
    self.test  = test
  }
}

extension SingletonDomain where Value:Equatable {
  public convenience init (value: Value) {
    self.init(value: value, test: ==)
  }
}

// MARK: Enumerated Domain

///
/// An `EnumeratedDomain` is a `Domain` with an arbitrary number of values in the domain matched
/// with a `test` function.  Worst case performance O(N) as the arbitrary values need to be tested
/// one-by-one.
///
public final class EnumeratedDomain<Value> : Domain<Value> {
  
  /// The enumerated values
  let values : [Value]
  
  /// the comparison predicate
  let test : (Value, Value) -> Bool
  
  public override func contains(_ value: Value) -> Bool {
    return values.contains { test(value, $0) }
  }
  
  public init (values: [Value], test: @escaping (Value, Value) -> Bool) {
    self.values = values
    self.test  = test
  }
}

extension EnumeratedDomain where Value:Equatable {
  public convenience init (values: Value...) {
    self.init(values: values, test: ==)
  }
}

// MARK: Set Domain

///
///The `SetDomain` is a `Domain` with a set of values.
///
public final class SetDomain<Value:Hashable> : Domain<Value> {
  
  /// The `Set` of values constituting the domain
  let set : Set<Value>

  ///
  public override func contains(_ value: Value) -> Bool {
    return set.contains(value);
  }
  
  public init (set: Set<Value>) {
    self.set = set
  }
  
  public convenience init (values: Value...) {
    self.init (set: Set<Value>(values))
  }
}

// MARK: Range Domain

///
/// A `RangeDomain` is a `Domain` with values determined by a `Range`
///
public final class RangeDomain<Value:Comparable> : Domain<Value> {
  
  /// The `Range` of the domain
  let range : Range<Value>
  
  public override func contains(_ value: Value) -> Bool {
    return range.contains (value)
  }

  public init (range: Range<Value>) {
    self.range = range
  }
}

// MARK: Complement Domain

///
/// A ComplementDomain is a Domain that complement another domain
///
public final class ComplementDomain<Value> : Domain<Value> {
  let domain : Domain<Value>
  
  public override func contains(_ value: Value) -> Bool {
    return !domain.contains(value)
  }
  
  public init (domain: Domain<Value>) {
    self.domain = domain
  }
}

// MARK: Compound Domain

///
/// DomainLogic is an Enumeration with .And and .Or and is used with a Compound Domain
///
public enum DomainLogic {
  case and
  case or
}

/// 
/// A `CompoundDomain` is a Domain comprised of a arbitary number of (sub)domains combined with
/// the provided DomainLogic 
///
public final class CompoundDomain<Value> : Domain<Value> {
  
  /// The domains
  let domains : [Domain<Value>]
  
  /// The logic
  let logic : DomainLogic
  
  public init (logic: DomainLogic, domains: Domain<Value>...) {
    self.logic   = logic
    self.domains = domains
  }
  
  public override func contains(_ value: Value) -> Bool {
    switch logic {
      case .and: return domains.all { $0.contains (value) }
      case .or : return domains.any { $0.contains (value) }
    }
  }
}

