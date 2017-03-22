Pod::Spec.new do |s|
  s.name = "MDEnvironmentManager"
  s.version = "0.10.0"
  s.summary = "Manage multiple environments. Includes the ability to serialize selected environments to the UserDefaults."
  s.description = <<-DESC
                     Represent environments in your app for multiple APIs.
                     Manage these in code or in a CSV file.
                     The selected environment can be persisted across app launches.
                     Also has support for production. You can define which environments are your production environments and have only them ship in your binary when doing a release build.
                   DESC
  s.homepage = "https://stash.mgmt.local/projects/IOSLIB/repos/mdenvironmentmanager/"
  s.license = 'Proprietary'
  
  s.author = { "Michael Leber" => "michael.leber@ihsmarkit.com" }
  s.source = { :git => "ssh://git@stash.mgmt.local/ioslib/mdenvironmentmanager.git", :tag => "#{s.version}" }

  s.platform = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  
  s.source_files  = "Source/**.{swift}"
  s.resource_bundles = {
    'MDEnvironmentManager' => ['Resources/*.storyboard']
  }

  s.dependency 'MD-Extensions'
  s.dependency 'CSV.swift', '~> 1.1'
end
