Pod::Spec.new do |s|
  s.name = 'SBVariables'
  s.version  = '0.1.0'
  s.summary  = 'Names, Ranges, Domains, Monitors, History and Variables'
  s.description = <<-DESC
A Variable is a Nameable, MonitoredObject that holds a time-series of values in a Domain.
DESC
  s.homepage = 'https://github.com/EBGToo/SBVariables'

  s.license  = 'MIT'
  s.authors = { 'Ed Gamble' => 'ebg@opuslogica.com' }
  s.source  = { :git => 'https://github.com/EBGToo/SBVariables.git',
                :tag => s.version }
  s.source_files = 'Sources/*.swift'

  s.osx.deployment_target = '10.9'

  s.dependency "SBUnits",  "~> 0.1"
  s.dependency "SBBasics", "~> 0.1"
end
