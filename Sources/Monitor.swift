//
//  Monitor.swift
//  SBVariables
//
//  Created by Ed Gamble on 10/22/15.
//  Copyright © 2015 Edward B. Gamble Jr.  All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//  See the CONTRIBUTORS file at the project root for a list of contributors.
//

///
/// A Monitor observes and reports on updates to a value.  The updated value is reported when two
/// conditions are met: 1) the monitor is not 'masked' and 2) the isReportable() func returns true.
/// The report is performed by the report() function.
///
/// A monitor can be masked by a call to mask().  The unmaskAndReset() function un-does the masking.
///
public class Monitor<Value> {
  
  /// True if Monitor is masked 
  var isMasked : Bool = false

  /// 
  /// Update the monitor with `value`.  Will report the update if the monitor is unmasked and if
  /// the `value` is 'reportable.
  ///
  /// - argument value: The updated value
  ///
  public func update (_ value: Value) {
    if !isMasked && isReportable(value) {
      report(value)
    }
  }

  ///
  /// Report the updated `value`.
  ///
  /// - argument value: The value to report.
  ///
  public func report (_ value: Value) {
  }

  ///
  /// Check if `value` is reportable
  ///
  /// - argument value: The value to check
  ///
  /// - returns: `true` if reportable; `false` otherwise.
  ///
  public func isReportable (_ value: Value) -> Bool {
    return true
  }

  ///
  /// Reset the monitor
  ///
  public func reset () {
  }
  
  ///
  /// Make the monitor 
  ///
  public func mask () { isMasked = true; }

  ///
  /// Unmask and reset the monitor
   
  public func unmaskAndReset () { isMasked = false; reset() }
  
  public init () {}
}

extension Monitor : Equatable {}
public func ==<Value> (lhs: Monitor<Value>, rhs: Monitor<Value>) -> Bool {
  return lhs === rhs
}

// MARK: On Change Monitor

///
/// An OnChangeMonitor reports an updated value if the value differs from the last value updated.
///
public class OnChangeMonitor<Value> : Monitor<Value> {
  
  /// The predicate to identify a changed value 
  public let changed : (Value, Value) -> Bool
  
  /// The lastValue updated 
  public internal(set) var lastValue : Value?

  ///
  /// Report the `value` change if 1) there is no `lastValue` or 2) the `lastValue` and `value`
  /// have changed.
  ///
  /// - argument: The value to check.
  ///
  /// - returns: `true` is changed; `false` otherwise.
  ///
  public override func isReportable(_ value: Value) -> Bool {
    return nil == lastValue || changed (value, lastValue!)
  }

  ///
  /// Update the monitor with `value`.  The provided `value` becomes the `lastValue` and is used for
  /// subsequent differences.
  ///
  /// - argument value: The updated value
  ///
  public override func update(_ value: Value) {
    super.update(value)
    lastValue = value
  }
  
  ///
  /// Create an instance
  ///
  /// - argument value: An optional as `lastValue`
  /// - argument changed: A function to determine a changed value.
  ///
  public init (value: Value? = nil, changed: @escaping (Value, Value) -> Bool) {
    self.lastValue = value
    self.changed = changed
  }
}

extension OnChangeMonitor where Value:Equatable {
  public convenience init (value: Value) {
    self.init (value: value, changed: !=)
  }
}

// MARK: Domain Monitor

///
/// A DomainMonitor reports an updated value if the value is in the `Domain`
///
public class DomainMonitor<Value> : Monitor<Value> {
  
  /// The domain 
  public let domain : Domain<Value>

  ///
  ///
  /// - argument value: The value to check
  ///
  /// - returns: `true` is `value` is out of range; `false` otherwise.
  ///
  public override func isReportable(_ value: Value) -> Bool {
    return domain.contains (value)
  }

  ///
  /// Create an instance
  ///
  /// - argument range: The valid range for value
  ///
  public init (domain: Domain<Value>) {
    self.domain = domain
  }
}

///
/// A PersistenceRangeMonitor reports an update value if the value is///inside* of a range for
/// an extended number of updates
  ///
public class PersistenceDomainMonitor<Value> : DomainMonitor<Value> {
  
  /// The current persistence count 
  public internal(set) var persistenceCount : Int = 0
  
  /// The specified persistence limit 
  public let persistenceLimit : Int

  public override func update (_ value: Value) {
    if !domain.contains(value) { persistenceCount = 0 }
    else { persistenceCount += 1 }

    super.update(value)
  }

  public override func isReportable(_ value: Value) -> Bool {
    return persistenceCount >= persistenceLimit
  }

  /// Reset the persistenceCount to zero 
  public override func reset () {
    self.persistenceCount = 0
  }
  
  ///
  /// Create an instance
  ///
  /// - argument limit: The persistence limit
  /// - argument range: The value range for value
  ///
  public init (limit: Int, domain: Domain<Value>) {
    self.persistenceLimit = limit
    super.init (domain: domain)
  }
}

// MARK: Monitorable

///
/// The Monitorable protocol
///
public protocol Monitorable {

  /// The Value monitored 
  associatedtype Value
  
  ///
  /// Check if `monitor`
  ///
  /// - argument monitor: The monitor to check
  ///
  /// - returns: `true` if contained; `false` otherwise
  ///
  func hasMonitor(_ monitor:Monitor<Value>) -> Bool
  
  ///
  /// Add monitor
  ///
  func addMonitor(_ monitor:Monitor<Value>)
  
  ///
  /// Remove monitor
  ///
  func remMonitor(_ monitor:Monitor<Value>)

  ///
  /// Check if `monitor` is accepted
  ///
  /// - argument monitor:
  ///
  /// - returns: `true` if accepted; `false` otherwise.
  ///
  func acceptsMonitor(_ monitor:Monitor<Value>) -> Bool

  ///
  /// Update the monitors for `value`
  ///
  func updateMonitorsFor(_ value: Value)
}

// MARK: Monitored Object

///
/// A MonitoredObject is a concrete implementation of `Monitorable`
/// 
public class MonitoredObject<Value> : Monitorable {
  
  /// Array of current monitors 
  var monitors = Array<Monitor<Value>>()
  
  public func hasMonitor(_ m: Monitor<Value>) -> Bool {
    return monitors.contains(m)
  }
  
  public func addMonitor(_ m: Monitor<Value>) {
    if acceptsMonitor(m) {
      monitors.append(m)
    }
  }
  
  public func remMonitor(_ m: Monitor<Value>) {
    if let index = monitors.firstIndex(of: m) {
      monitors.remove(at: index)
    }
  }
  
  public func acceptsMonitor(_ m: Monitor<Value>) -> Bool {
    return true
  }
  
  public func updateMonitorsFor(_ value: Value) {
    for monitor in monitors {
      monitor.update(value)
    }
  }
}

