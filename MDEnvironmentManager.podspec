Pod::Spec.new do |s|
  s.name = "MDEnvironmentManager"
  s.version = "3.0.1"
  s.summary = "Manage multiple environments. Includes the ability to serialize selected environments to the UserDefaults."
  s.description = <<-DESC
                     Represent environments in your app for multiple APIs.
                     Manage these in code or in a CSV file.
                     The selected environment can be persisted across app launches.
                     Also has support for production. You can define which environments are your production environments and have only them ship in your binary when doing a release build.
                     Support also exists for adding custom environments that can be persisted, deleted, and used.
                   DESC
  s.homepage = "https://github.com/markitondemand/EnvironmentManager"
  s.license = 'Proprietary'
  
  s.author = { "Michael Leber" => "michael.leber@ihsmarkit.com" }
  s.source = { :git => "https://github.com/markitondemand/EnvironmentManager.git", :tag => "#{s.version}" }

  s.platform = :ios, "9.0"
  s.ios.deployment_target = '9.0'
  
  s.source_files  = "Source/**.{swift}"
  s.resource_bundles = {
    'MDEnvironmentManager' => ['Resources/*.storyboard']
  }

  s.dependency 'MD-Extensions', '~>0'
  s.dependency 'CSV.swift', '~> 2.0'
end
