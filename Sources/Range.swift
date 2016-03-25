//
//  Range.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBCommons

// MARK: Range

///
/// A `Range` defines one or more contiguous regions containing comparable values.  The `contains`
/// function determines if a provided value is in the `range`.  A range can be complemented;
/// two ranges can be composed by union(or/any) or intersection(and/all).
///
public class Range<Value: Comparable> {
  
  /// Check if Range contains `value`
  ///
  /// - parameter value: The value to check
  ///
  /// - returns `true` if `value` is contained; otherwise `false`
  ///
  func contains (_ value: Value) -> Bool {
    return false
  }
  
  ///
  /// Intersection of two ranges.  The `contain` function is the `and` of the ranges.
  ///
  /// - parameter that: the other range
  ///
  /// - returns: The intersection of `self` and `that`
  ///
  func intersection (_ that: Range<Value>) -> Range<Value> {
    return CompoundRange (logic: .all, self, that)
  }
  
  ///
  /// Union of two ranges.  The `contain` function is the `or` of the ranges.
  ///
  /// - parameter that: the other range
  ///
  /// - returns: The union of `self` and `that`
  ///
  func union (_ that: Range<Value>) -> Range<Value> {
    return CompoundRange (logic: .any, self, that)
  }
  
  ///
  /// Complement of a range
  ///
  /// - returns: The complement of `self`
  ///
  var complement : Range<Value> {
    return ComplementRange<Value>(range: self)
  }
  
  ///
  /// Check if `self` shadows `that`.  If the computation cannot be performed, then nil is returned
  ///
  /// - parameter that: the other range
  ///
  /// - returns: .None if the shadow cannot be determined; `true` if shadows; otherwise `false.
  ///
  func shadows (_ that: Range<Value>) -> Bool? {
    return nil
  }
}

// MARK: ContiguousRange

///
/// A `ContiguousRange` is a `Range` with values between optional minimum and maximum limits.  The
/// minimum and maximum can be included (closed), not-included (open) or nil (unbounded).
///
public final class ContiguousRange <Value: Comparable> : Range<Value> {
  
  /// The optional minimum; if `nil` then 'Value:-infinity' (no minimum)
  public let minimum : Value?
  
  /// For `minimum` - `true` if 'included/closed'; `false` if 'excluded/open'
  public let incMinimum : Bool

  /// The optional maximum; if `nil` then 'Value:+infinity' (no maximum)
  public let maximum : Value?

  /// For `maximum` - `true` if 'included/closed'; `false` if 'excluded/open'
  public let incMaximum : Bool

  ///
  /// Initialize an instance
  ///
  /// - parameter minimum:
  /// - parameter incMinimum:
  /// - parameter maximum:
  /// - parameter incMaximum:
  ///
  public init (
    minimum: Value?, incMinimum: Bool = true,
    maximum: Value?, incMaximum: Bool = false) {
      // Order maximum and minimum?  If min > max; then contains === false
      self.maximum     = maximum
      self.incMaximum  = incMaximum
      self.minimum     = minimum
      self.incMinimum  = incMinimum
  }

  ///
  /// Initialize an instance
  ///
  /// - parameter minimum:
  /// - parameter incMinimum
  ///
  public convenience init (minimum: Value, incMinimum: Bool = true) {
    self.init (minimum: minimum, incMinimum: incMinimum,
      maximum: nil, incMaximum: false)
  }

  ///
  /// Initialize an instance
  ///
  /// - parameter maximum:
  /// - parameter incMaximum:
  ///
  public convenience init (maximum: Value, incMaximum: Bool = false) {
    self.init (minimum: nil, incMinimum: false,
      maximum: maximum, incMaximum: incMaximum)
  }

  ///
  /// Check if `value` is contained
  ///
  /// - parameter value:
  ///
  public override func contains (_ value: Value) -> Bool {
    return
      (nil == minimum ||
        (incMinimum ? minimum! <= value  : minimum! < value  )) &&
      (nil == maximum ||
        (incMaximum ? value   <= maximum! : value  < maximum!))
  }
  
  ///
  /// Produce the intersection of `self` and `that`
  ///
  /// - parameter that:
  /// - returns: the intersection
  ///
  public override func intersection (_ that: Range<Value>) -> Range<Value> {
    if let that = that as? ContiguousRange<Value> {
      let imin = ContiguousRange.upperBound (minimum, that.minimum)
      let imax = ContiguousRange.lowerBound (maximum, that.maximum)

      if nil != imin && nil != imax && imin! > imax! {
        return super.intersection(that)
      }

      return ContiguousRange<Value> (
        minimum: imin, incMinimum: incMinimum || that.incMinimum,
        maximum: imax, incMaximum: incMaximum || that.incMaximum)
    }
    else {
      return super.intersection (that)
    }
  }
  
  ///
  /// Produce the complement of `self`
  ///
  /// - returns: the complement
  ///
  public override var complement : Range<Value> {
    switch (minimum, maximum) {
    case let (.some(min), .some(max)):
      return CompoundRange<Value>(logic: .all,
        arrayOfRanges: [ContiguousRange<Value>(minimum: nil, maximum: min, incMaximum: !incMinimum),
                        ContiguousRange<Value>(minimum: max, incMinimum: !incMaximum, maximum: nil)])
      
    case let (.some(min), .none):
      return ContiguousRange<Value>(minimum: nil, maximum: min, incMaximum: !incMinimum)
      
    case let (.none, .some(max)):
      return ContiguousRange<Value>(minimum: max, incMinimum: !incMaximum, maximum: nil)
      
    case (.none, .none):
      return super.complement // Always false
    }
  }
  
  ///
  /// Check if `self` shadows `that`
  ///
  /// - parameter that:
  /// - returns: 
  ///
  public override func shadows (_ that: Range<Value>) -> Bool? {
    guard let that = that as? ContiguousRange<Value> else { return nil }

    //    return (minimum < that.minimum || (incMinimum && minimum == that.minimum))
    //      &&   (maximum > that.maximum || (incMaximum && maximum == that.maximum))

    return ContiguousRange.minBelow (minimum, that.minimum, incMinimum)
        && ContiguousRange.maxAbove (maximum, that.maximum, incMaximum)
  }

  internal static func minBelow (_ a: Value?, _ b: Value?, _ inc: Bool) -> Bool {
    if a == nil { return true }  // a = -infinity is always below
    if b == nil { return false } // b = -infinity is always above a /= -infinity
    return a! < b! || (inc && a! == b!)
  }

  internal static func maxAbove (_ a: Value?, _ b: Value?, _ inc: Bool) -> Bool {
    if a == nil { return true }  // a = +infinity is always above
    if b == nil { return false } // b = +infinity is always below a /= +infinity
    return a! > b! || (inc && a! == b!)
  }




  /// Return the lower bound from two optional values.  If either value is nil, the result is nil.
  internal static func lowerBound (_ a: Value?, _ b: Value?) -> Value? {
    switch (a, b) {
    case let (.some(a), .some(b)): return min (a, b)
    default: return nil
    }
  }
  
  /// Return the upper bound from two optional values.  If either value is nil, the result is nil.
  internal static func upperBound (_ a: Value?, _ b: Value?) -> Value? {
    switch (a, b) {
    case let (.some(a), .some(b)): return max (a, b)
    default: return nil
    }
  }
}

// MARK: ComplementRange

///
/// A `ComplementRange` inverts a base range
///
public final class ComplementRange<Value:Comparable> : Range<Value> {
  
  /// The base range
  let range : Range<Value>
  
  public override func contains(_ value: Value) -> Bool {
    return !range.contains(value)
  }
  
  ///
  /// Produce the complement of `self`.  The complement of a complement range is the base range
  /// itself.
  ///
  /// - returns: the base range.
  ///
  public override var complement : Range<Value> {
    return range
  }
  
  /// Initialize an instance
  public init (range: Range<Value>) {
    self.range = range
  }
}

// MARK: Compound Range

/// A CompoundRangeLogic enumeration defines .All and .Any for CompoundRange.
public enum CompoundRangeLogic {
  case all
  case any
}

///
/// A `CompoundRange` combines an arbitrary number of Ranges using .All or .Any logic
///
public final class CompoundRange<Value:Comparable> : Range<Value> {
  let ranges : [Range<Value>]
  let logic  : CompoundRangeLogic
  
  public override func contains(_ value: Value) -> Bool {
    switch logic {
    case .all: return ranges.all { $0.contains(value) }
    case .any: return ranges.any { $0.contains(value) }
    }
  }
  
  public convenience init (logic: CompoundRangeLogic, _ ranges: Range<Value>...) {
    self.init (logic: logic, arrayOfRanges: ranges)
  }
  
  public init (logic: CompoundRangeLogic, arrayOfRanges: [Range<Value>]) {
    self.ranges = arrayOfRanges
    self.logic  = logic
  }
}
