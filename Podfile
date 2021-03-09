# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'rtc-quickdemo-ios'

project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
project 'quickdemo-live/quickdemo-live.xcodeproj'
project 'quickdemo-live/quickdemo-liveAcross.xcodeproj'
project 'quickdemo-callKit/quickdemo-callKit.xcodeproj'
project 'quickdemo-calllib/quickdemo-calllib.xcodeproj'
project 'quickdemo-meeting-beauty/quickdemo-meeting-beauty.xcodeproj'

abstract_target 'CommonPods' do
    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!
    platform :ios, '9.0'

    target 'quickdemo-meeting-1v1' do
        project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
        pod 'RongRTCLib', '~> 5.1.0'
    end

    target 'quickdemo-live' do
        project 'quickdemo-live/quickdemo-live.xcodeproj'
        pod 'RongRTCLib', '~> 5.1.0'
    end
    
    target 'quickdemo-liveAcross' do
        platform :ios, '9.0'
        project 'quickdemo-liveAcross/quickdemo-liveAcross.xcodeproj'
        pod 'RongRTCLib', '~> 5.1.0'
    end
    
    target 'quickdemo-callkit' do
        project 'quickdemo-callkit/quickdemo-callkit.xcodeproj'
        pod 'RongCloudRTC/RongCallKit', '~> 5.1.0'
    end

    target 'quickdemo-calllib' do
        project 'quickdemo-calllib/quickdemo-calllib.xcodeproj'
        pod 'RongCloudRTC/RongCallLib', '~> 5.1.0'
    end
    
    target 'quickdemo-meeting-beauty' do
      project 'quickdemo-meeting-beauty/quickdemo-meeting-beauty.xcodeproj'
      pod 'RongRTCLib', '~> 5.1.0'
    end
end
