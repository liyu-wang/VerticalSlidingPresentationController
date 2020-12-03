Pod::Spec.new do |s|
    s.name = 'VerticalSlidingPresentationController'
    s.version = '0.1.3'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.summary = 'Vertical Sliding custom view controller presentation animation'
    s.homepage = 'https://github.com/liyu-wang/VerticalSlidingPresentationController'
    s.authors = { 'Liyu Wang' => 'sense777cn@gmail.com' }
    s.source = { :git => 'https://github.com/liyu-wang/VerticalSlidingPresentationController.git', :tag => s.version }
    
    s.platform = :ios
    s.ios.deployment_target = '11.0'
  
    s.swift_versions = ['5.1', '5.2', '5.3']
  
    s.source_files = 'VerticalSlidingPresentationController/Sources/*.swift'

    s.framework = "UIKit"
  
  end