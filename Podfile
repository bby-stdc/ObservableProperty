workspace 'ObservableProperty'

use_frameworks!
inhibit_all_warnings!

project 'ObservableProperty'

target "ObservablePropertyTests" do
   project 'ObservableProperty'
   platform :ios, "9.0"
   pod 'Quick', :git => 'https://github.com/Quick/Quick.git', :branch => 'swift-3.0'
   pod 'Nimble'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
