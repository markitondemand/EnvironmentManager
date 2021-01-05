# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

source 'https://github.com/markitondemand/MDPodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Example' do
  use_frameworks!

  pod 'MDEnvironmentManager', :path => './MDEnvironmentManager.podspec'
end

target 'MDEnvironmentManager' do
  use_frameworks!
  
  # Pods for MDEnvironmentManager
  pod 'MDEnvironmentManager', :path => './MDEnvironmentManager.podspec'
  
  target 'MDEnvironmentManagerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
