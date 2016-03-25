# Names, Ranges, Domains, Monitors, History and Variables


![License](https://img.shields.io/cocoapods/l/SBVariables.svg)
[![Language](https://img.shields.io/badge/lang-Swift-orange.svg?style=flat)](https://developer.apple.com/swift/)
![Platform](https://img.shields.io/cocoapods/p/SBVariables.svg)
![](https://img.shields.io/badge/Package%20Maker-compatible-orange.svg)
[![Version](https://img.shields.io/cocoapods/v/SBVariables.svg)](http://cocoapods.org)

## Features

### Range

A `Range` defines one or more contiguous regions containing comparable values.  The `contains`
function determines if a provided value is in the `range`.  The `Range` can be complemented;
two ranges can be composed by union(or/any) or intersection(and/all).

Defined Ranges include:

* ContiguousRange - a range with values between optional minimum and maximum value.  The minimum and
maximum can be included (closed), not-included (open) or nil (unbounded).
* ComplementRange - a range that complements a base range
* CompoundRange - a range that logically combines, using .Any ('or') or .All ('and'), an arbitary
number of other ranges.

### Domain

A Domain defines a set of values based on a predicate.  Generally a Domain represents a subset of 
values from the value's type.  Thus, for example, for an Int a RangeDomain represents integers
betweeen some minimum and maximum values.  A SingletonDomain for a String defines a single string
as in the domain.  

Defined Domains include:

* AlwaysDomain - a domain that returns `true` or `false` (as initialited) for any value
* SingletonDomain - a domain that holds a single value and a comparison function
* EnumeratedDomain - a domain that holds a list of values and a comparison function
* SetDomain - a domain that holds a set of hashable values
* RangeDomain - a domain that holds a range of comparable values.  The minimum and maximum can be
included (closed), not-included (open) or nil (unbounded).
* ComplementDomain - a domain that is the complement of another domain
* CompoundDomain - a domain that logically combines, using .And or .Or, an arbitrary number of other
domains

### Monitor

A Monitor observes and reports on updates to a value.  The updated value is reported when two
conditions are met: 1) the monitor is not 'masked' and 2) the isReportable() func returns true.
The report is performed by the report() function. A monitor can be masked by a call to mask().  
The unmaskAndReset() function un-does the masking.

Defined Monitors include
* OnchangeMonitor - a monitor that reports when the updated value changes from the lastValue.  This
domain is initialized with 'lastValue' and with a comparison function.
* DomainMonitor - a monitor that reports when the updated value is IN the provided domain
* PersistenceDomainMonitor - a domain monitor that reports when the updated value is in the provided
domain for a provided persistenceLimit.  

A Monitorable is a protocol for objects that are monitored.  Monitors are added and removed from a
Monitorable; the updateMonitorsFor:value function updates each monitor.  Calling updateMonitorsFor
is subclass dependent.  A Monitorable has an associated type constraint.

A MonitoredObject<Value> is a concrete base-class for Monitorable.

### History

A History maintains a time-stamped history of values.

### Variable

A Variable<Value> is a Nameable, MonitoredObject<Value> that holds values in a defined domain and
that optionally maintains a history of assigned values.  The assign:value:time function updates the
variable's value; the assignment may fail if the value to be assigned is not in the Variable's
domain.  Additionally, a VariableDelegate can prevent an assignement.

As a MonitoredObject, on assignment the variable's monitors are updated with the assigned value.

### Name

A `Nameable` has a name (as a String).

## Usage

```swift
import SBVariables
```

## Installation

Three easy installation options:

### Apple Package Manager

In your Package.swift file, add a dependency on SBVariables:

```swift
import PackageDescription

let package = Package (
  name: "<your package>",
  dependencies: [
    // ...
    .Package (url: "https://github.com/EBGToo/SBVariables.git",  majorVersion: 0),
    // ...
  ]
)
```

### Cocoa Pods

```ruby
pod 'SBVariables', '~> 0.1'
```

### XCode

```bash
$ git clone https://github.com/EBGToo/SBVariables.git SBVariables
```

You'll also need the [SBCommons](https://github.com/EBGToo/SBCommons), 
[SBUnits](https://github.com/EBGToo/SBUnits) and 
[SBBasics](https://github.com/EBGToo/SBBasics) frameworks.  With those, add the SBVariables Xcode Project to your Xcode Workspace.
