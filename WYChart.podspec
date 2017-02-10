#
# Be sure to run `pod lib lint WYChart.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WYChart'
  s.version          = '0.3.1'
  s.summary          = 'A simple and elegant Chart library with rich animations.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'WYChart is a chart library contained lineChart and pieChart, you can use it with numbers of line of code,
                        all the charts also performing rich animations, and interacting in a vivid way.'

  s.homepage         = 'https://github.com/GeorgeWang03/WYChart'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'FreedomKing' => 'georgewang003@gmail.com' }
  s.source           = { :git => 'https://github.com/GeorgeWang03/WYChart.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WYChart/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WYChart' => ['WYChart/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
