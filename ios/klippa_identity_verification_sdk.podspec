Pod::Spec.new do |s|
  s.name             = 'klippa_identity_verification_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Allows you to do identity verification with the Klippa Identity Verification SDK from Flutter apps.'
  s.description      = <<-DESC
Allows you to do identity verification with the Klippa Identity Verification SDK from Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/klippa-app/flutter-klippa-identity-verification-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Klippa App BV' => 'jeroen@klippa.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Klippa-Identity-Verification'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice. Klippa Identity SDK does not contain a arm64 slice for simulators.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
  s.swift_version = '5.0'
end
