require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'ExpoGbping'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/sincerely-manny/expo-gbping' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  # s.dependency 'GBPing', '~> 1.5.1'

  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  # s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
  s.source_files = [
    "**/*.{h,m,mm,swift,hpp,cpp}",
    "ExpoGbping-Bridging-Header.h",
    "vendor/GBPing/**/*.{h,m}"
  ]
  s.public_header_files = 'vendor/GBPing/**/*.h'
  s.header_mappings_dir = 'vendor/GBPing'
end
