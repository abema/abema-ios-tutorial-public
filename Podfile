source 'https://cdn.cocoapods.org/'

workspace 'Pods/_Unused.xcworkspace'
project './AbemaTutorial.xcodeproj'

use_frameworks! :linkage => :static
inhibit_all_warnings!

deployment_target = '13.0'
platform :ios, '13.0'

$rx_version = '6.5.0'

def app_proj
    project './AbemaTutorial.xcodeproj'
end

def rxswift
  pod 'RxSwift', $rx_version
end

def rxrelay
  pod 'RxRelay', $rx_version
end

def rxcocoa
  pod 'RxCocoa', $rx_version
end

def rxtest
  pod 'RxTest', $rx_version
end

def rxblocking
  pod 'RxBlocking', $rx_version
end

def rxaction
  pod 'Action', '5.0.0'
end

def unio
  pod 'Unio', '0.11.0'
end

target 'AbemaTutorial' do
    app_proj

    rxswift
    rxrelay
    rxcocoa
    rxaction
    unio

    ## Tool
    pod 'SwiftLint', '0.47.0'
    pod 'SwiftGen', '6.5.1'
end

target 'Extension' do
  rxswift
  rxrelay
end

target 'TestExtension' do
  rxtest
end

target 'ExtensionTests' do
  rxswift
  rxrelay

  rxtest
end

target 'Domain' do
  rxswift
  rxrelay
end

target 'DomainTests' do
  rxswift
  rxrelay

  rxtest
end

target 'Repository' do
  rxswift
end

target 'RepositoryTests' do
  rxswift
  rxrelay
  rxtest
end

target 'UIComponent' do
  rxswift
  rxrelay
  rxcocoa
  unio
end

target 'XcodePreviews' do
  rxswift
  rxrelay
  rxcocoa
  unio
end

target 'UILogic' do
  rxswift
  rxrelay
  rxcocoa
  unio
end

target 'UILogicTests' do
  rxswift
  rxrelay
  rxcocoa
  unio

  rxtest
end

target 'UILogicInterface' do
  rxswift
  rxrelay
  rxcocoa
  unio
end

target 'UseCase' do
  rxswift
  rxrelay
end

target 'UseCaseTests' do
  rxswift
  rxrelay

  rxtest
end

target 'UseCaseInterface' do
  rxswift
  rxrelay
end

post_install do |installer|
  # Workaround for Xcode12
  # https://qiita.com/temoki/items/46ad22940e819a132435
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
  end
end
