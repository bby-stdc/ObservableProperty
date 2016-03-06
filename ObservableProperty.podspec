Pod::Spec.new do |s|
    s.name             = "ObservableProperty"
    s.version          = "0.1.3"
    s.summary          = "A one-to-many observable property"
    s.description      = <<-DESC
                          A one-to-many observable property for Swift, including error propagation.
    DESC
    s.homepage         = "https://github.com/jedlewison/ObservableProperty"
    s.license          = 'MIT'
    s.author           = { "Jed Lewison" => "jed@.....magic....app....factory.com" }
    s.source           = { :git => "https://github.com/jedlewison/ObservableProperty.git", :tag => s.version.to_s }
    s.ios.deployment_target = '9.0'
    s.requires_arc = true
    s.source_files = 'ObservableProperty/*.{h,swift}'
    s.dependency 'SwiftSynchronized'
end
