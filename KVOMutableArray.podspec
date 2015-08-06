#
# Be sure to run `pod lib lint KVOMutableArray.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "KVOMutableArray"
  s.version          = "1.0.2"
  s.summary          = "A mutable array which can be key value observed (KVO)."
  s.description      = <<-DESC
                       KVOMutableArray provides the functionality to observe a NSMutableArray.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/haifengkao/KVOMutableArray"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Hai Feng Kao" => "haifeng@cocoaspice.in" }
  s.source           = { :git => "https://github.com/haifengkao/KVOMutableArray.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.subspec 'Core' do |sp|
    sp.source_files = 'Pod/Classes/KVOMutableArray.{h,m}', 'Pod/Classes/NSObject+BlockObservation.{h,m}', 'Pod/Classes/KVOMutableArrayObserver.{h,m}'
  end

  s.subspec 'ReactiveCocoaSupport' do |sp|
    sp.dependency 'ReactiveCocoa/Core'
    sp.dependency 'KVOMutableArray/Core'
    sp.source_files = 'Pod/Classes/KVOMutableArray+ReactiveCocoaSupport.{h,m}'
  end

  s.default_subspec = 'Core'
  s.public_header_files = 'Pod/Classes/**/{KVOMutableArray,NSObject+BlockObservation}.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
