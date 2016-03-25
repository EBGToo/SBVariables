//
//  Variable.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

import SBUnits

public struct VariableDelegate<Value> {
  public var canAssign = { (variable: Variable<Value>, value:Value) -> Bool in return true }

  public var didAssign = { (variable: Variable<Value>, value:Value) -> Void in return }

  public var didNotAssign = { (variable: Variable<Value>, value:Value) -> Void in return }
    
  public init (
    canAssign    : ((_ variable: Variable<Value>, _ value:Value) -> Bool)?,
    didAssign    : ((_ variable: Variable<Value>, _ value:Value) -> Void)? = nil,
    didNotAssign : ((_ variable: Variable<Value>, _ value:Value) -> Void)? = nil)
  {
    self.canAssign    = canAssign    ?? self.canAssign
    self.didAssign    = didAssign    ?? self.didAssign
    self.didNotAssign = didNotAssign ?? self.didNotAssign
  }
  
  public init () {}
}

///
/// A Variable is a Nameable, MonitoredObject that holds a time-series of values in a Domain.  The
/// variable's value is updated when assigned; if the assigned value is not in the domain then ...;
/// if the variable's delegate returns `false` for `canAssign:variable:value` then ...  If a
/// `History<Value>` is associated with the variable then upon assignemet, the history is extended.
///
public class Variable<Value> : MonitoredObject<Value>, Nameable {
  
  /// The variable name 
  public let name : String

  /// The variable domain 
  public let domain : Domain<Value>

  /// The variable value 
  public internal(set) var value : Value

  /// The variable time of last assignment
  public internal(set) var time : Quantity<Time>
  
  /// The variable delegate
  public var delegate : VariableDelegate<Value>

  /// The optional variable history
  public internal(set) var history : History<Value>?

  /// Initialize an instance.  This is `Optional` because the provided `value` must be in `domain`
  /// for the initialization to succeeed.
  ///
  /// - parameter name:
  /// - parameter time:
  /// - parameter value:
  /// - parameter domain:
  /// - parameter history:
  /// - parameter delegate
  ///
  public init? (name: String, time:Quantity<Time>, value: Value, domain: Domain<Value>,
    history : History<Value>? = nil,
    delegate : VariableDelegate<Value> = VariableDelegate<Value>()) {

      // Initialize everything - even though we've not checked domain.contains(value) yet
      self.name  = name
      self.value = value
      self.time  = time;
      self.domain   = domain
      self.delegate = delegate
      self.history  = history
      
      // Required after everything initialized and before anything more.
      super.init()

      // Ensure `domain` contains `value`
      guard domain.contains(value) else { return nil }

      // Formalize the assignment
      assign(value, time: time)
  }

  ///
  /// Assign `value`.
  ///
  /// - parameter value:
  /// - parameter time:
  ///
  public func assign (_ value: Value, time:Quantity<Time>) {
    guard domain.contains(value) && delegate.canAssign(self, value) else {
      delegate.didNotAssign(self, value)
      return
    }
    
    self.value = value
    history?.extend (time, value: value)
    updateMonitorsFor(value)
    delegate.didAssign(self, value)
  }
}

///
/// A QuantityVariable is a Variable with value of type Quantity<D> where D is an Dimension (such
/// as Length, Time or Mass).
///
public class QuantityVariable<D:SBUnits.Dimension> : Variable<Quantity<D>> {
  public override init? (name: String, time:Quantity<Time>, value: Quantity<D>, domain: Domain<Quantity<D>>,
    history : History<Quantity<D>>? = nil,
    delegate : VariableDelegate<Quantity<D>> = VariableDelegate<Quantity<D>>()) {
      super.init(name: name, time: time, value: value, domain: domain, history: history, delegate: delegate)
  }
}

