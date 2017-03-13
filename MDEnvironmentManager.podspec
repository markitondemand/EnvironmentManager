Pod::Spec.new do |s|
  s.name = "MDEnvironmentManager"
  s.version = "0.7.0"
  s.summary = "Manage multiple environments. Includes the ability to serialize selected environments to the UserDefaults."
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
