//: Playground - noun: a place where people can play

import SBCommons
import SBBasics
import SBUnits
import SBVariables

var theTime = Quantity<Time>(value: 0.0, unit: second)

// 'Room Temperature'

// Range - Values up to 75.0 C
var theTemperatureRange = ContiguousRange<Quantity<Temperature>>(maximum: Quantity<Temperature>(value: 75.0, unit: celsius))
theTemperatureRange.contains(Quantity<Temperature>(value: 70.0, unit: celsius))
theTemperatureRange.contains(Quantity<Temperature>(value: 80.0, unit: celsius))

// RangeDomain - Values up to 75.0 C
var theTemperatureDomain = RangeDomain<Quantity<Temperature>>(range: theTemperatureRange)
theTemperatureDomain.contains(Quantity<Temperature>(value: 70.0, unit: celsius))
theTemperatureDomain.contains(Quantity<Temperature>(value: 80.0, unit: celsius))

// Variable
var roomTemperature = Variable<Quantity<Temperature>>(name: "OfficeTemperature", time: theTime,
  value: Quantity<Temperature>(value: 50.0, unit: celsius),
  domain: AlwaysDomain<Quantity<Temperature>>(result: true),
  history: History<Quantity<Temperature>>(capacity: 3))!

// Monitor
var roomTemperatureMonitor = DomainMonitor<Quantity<Temperature>>(domain: RangeDomain<Quantity<Temperature>>(
  range: ContiguousRange<Quantity<Temperature>>(maximum: Quantity<Temperature>(value: 75.0, unit: celsius))))

roomTemperatureMonitor.isReportable(Quantity<Temperature>(value: 70.0, unit: celsius))
roomTemperatureMonitor.isReportable(Quantity<Temperature>(value: 80.0, unit: celsius))

roomTemperature.addMonitor(roomTemperatureMonitor)

// Variable -- Assigne Values
roomTemperature.assign(Quantity<Temperature>(value: 60.0, unit: celsius),
  time: Quantity<Time>(value: 1.0, unit: second))

roomTemperatureMonitor.isReportable(roomTemperature.value)

roomTemperature.assign(Quantity<Temperature>(value: 70.0, unit: celsius),
  time: Quantity<Time>(value: 2.0, unit: second))

roomTemperatureMonitor.isReportable(roomTemperature.value)

roomTemperature.assign(Quantity<Temperature>(value: 80.0, unit: celsius),
  time: Quantity<Time>(value: 3.0, unit: second))

roomTemperatureMonitor.isReportable(roomTemperature.value)

// 'Person Mass'

var personMass = QuantityVariable<Mass>(name: "PersonMass", time: theTime,
  value: Quantity<Mass>(value: 175.0, unit: pound),
  domain: AlwaysDomain<Quantity<Mass>>(result: true))!

var personMassAssignments = [Quantity<Mass>]()
var personMassDelegate = VariableDelegate<Quantity<Mass>>()
personMassDelegate.didAssign = { (variable: Variable<Quantity<Mass>>, value:Quantity<Mass>) -> Void in
  print (value)
  personMassAssignments.append(value)
  return
}
personMass.delegate = personMassDelegate

personMass.assign(Quantity<Mass>(value: 180.0, unit: pound),
  time: Quantity<Time>(value: 2.0, unit: second))

personMass.value
personMassAssignments

personMass.assign(Quantity<Mass>(value: 185.0, unit: pound),
  time: Quantity<Time>(value: 2.0, unit: second))

personMass.value
personMassAssignments
