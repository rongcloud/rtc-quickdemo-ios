# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'rtc-quickdemo-ios'

project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
project 'quickdemo-live/quickdemo-live.xcodeproj'
project 'quickdemo-callKit/quickdemo-callKit.xcodeproj'

abstract_target 'CommonPods' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    pod 'Masonry'

    target 'quickdemo-meeting-1v1' do
        platform :ios, '9.0'
        project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
        pod 'RongRTCLib'
    end

    target 'quickdemo-live' do
        platform :ios, '9.0'
        project 'quickdemo-live/quickdemo-live.xcodeproj'
        pod 'RongRTCLib'
    end
    
    target 'quickdemo-callkit' do
        platform :ios, '9.0'
        project 'quickdemo-callkit/quickdemo-callkit.xcodeproj'
        pod 'RongCloudRTC'
    end
end
