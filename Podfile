platform :ios, '9.0'
use_frameworks!

workspace 'rtc-quickdemo-ios'

project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
project 'quickdemo-live/quickdemo-live.xcodeproj'
project 'quickdemo-live/quickdemo-live-pk.xcodeproj'
project 'quickdemo-callKit/quickdemo-callkit.xcodeproj'
project 'quickdemo-calllib/quickdemo-calllib.xcodeproj'
project 'quickdemo-imkit-callkit/quickdemo-imkit-callkit.xcodeproj'
project 'quickdemo-meeting-beauty/quickdemo-meeting-beauty.xcodeproj'

abstract_target 'CommonPods' do
    use_frameworks!
    platform :ios, '9.0'

    target 'quickdemo-meeting-1v1' do
        project 'quickdemo-meeting-1v1/quickdemo-meeting-1v1.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-live' do
        project 'quickdemo-live/quickdemo-live.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-live-pk' do
        platform :ios, '9.0'
        project 'quickdemo-live-pk/quickdemo-live-pk.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-imkit-callkit' do
        project 'quickdemo-imkit-callkit/quickdemo-imkit-callkit.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-callkit' do
        project 'quickdemo-callkit/quickdemo-callkit.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-calllib' do
        project 'quickdemo-calllib/quickdemo-calllib.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end

    target 'quickdemo-meeting-beauty' do
        project 'quickdemo-meeting-beauty/quickdemo-meeting-beauty.xcodeproj'
        pod 'RongCloudRTC', '~> 5.1.0'
    end
end
