#
# Be sure to run `pod lib lint MSSerialPort.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MSSerialPort'
  s.version          = '0.0.7'
  s.summary          = '玛格智能家居串口控制命令'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "-"
  s.homepage         = 'https://gitlab.com/JeasonLee/MSSerialPort'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JeasonLee' => 'jeason.l@qq.com' }
  s.source           = { :git => 'https://gitlab.com/JeasonLee/MSSerialPort.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_versions = '5.0'

  s.subspec 'Product' do |ss|
    ss.source_files = 'MSSerialPort/Classes/Product/**/*'
  end
  
  s.subspec 'Util' do |ss|
    ss.source_files = 'MSSerialPort/Classes/Util/*'
  end
  
  # s.source_files = 'MSSerialPort/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MSSerialPort' => ['MSSerialPort/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
