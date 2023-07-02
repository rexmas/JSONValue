#
# Be sure to run `pod lib lint JSONValueRX.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JSONValueRX"
  s.version          = "8.0.0"
  s.summary          = "Simple Swift JSON representation supporting subscripting and pattern matching."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Simple Swift JSON representation supporting subscripting and pattern matching. JSONValue uses an algebraic datatype representation of JSON for type safety and pattern matching.
                       DESC

  s.homepage         = "https://github.com/rexmas/JSONValue"
  s.license          = 'MIT'
  s.author           = { "rexmas" => "rex.fenley@gmail.com" }
  s.source           = { :git => "https://github.com/rexmas/JSONValue.git", :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.swift_version = '5.8.1'
  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
  s.resource_bundles = {
  }

end
