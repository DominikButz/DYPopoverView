
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DYPopoverView'
  s.version          = '1.0'
  s.summary          = 'SwiftUI implementation of a popover view with arrow'
  s.swift_version = '5.1'


  s.description      = <<-DESC
    DYPopoverView is a SwiftUI implementation of a popover view with arrow.
It can only be used from iOS 13.0 or iPadOS because SwiftUI is not supported in earlier iOS versions.
                       DESC

  s.homepage    = 'https://github.com/DominikButz/DYPopoverView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dominikbutz' => 'dominikbutz@gmail.com' }
  s.source           = { :git => 'https://github.com/DominikButz/DYPopoverView.git', :tag => s.version.to_s }

 s.platform           = :ios
 s.ios.deployment_target = '13.0'


  s.source_files = 'Sources/**/*'
  #s.exclude_files = 'DYPopoverView /**/*.plist'


  # s.public_header_files = 'DYPopoverView/**/*.h'

end
