# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'ssh://git@stash.mgmt.local/ioslib/markitpodspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

target 'Example' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Example
  #TODO: update to our podspec whe nwe add it
#  pod 'MDTestAccountManager', :path => './MDTestAccountManager.podspec'

end

target 'MDEnvironmentManager' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MDEnvironmentManager
#  pod 'MDTestAccountManager', :path => './MDTestAccountManager.podspec'
  pod 'MD-Extensions'
  target 'MDEnvironmentManagerTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
