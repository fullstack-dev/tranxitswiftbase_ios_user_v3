# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'

target 'TranxitUser' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

    #Alamofire Webservices
    pod 'Alamofire'
    pod 'AlamofireObjectMapper'
    
    #Reachability Network check
    pod 'ReachabilitySwift'
    
    #Google
    pod 'GoogleMaps'
    pod 'GoogleSignIn'
    pod 'GooglePlaces'
    
    #Firebase
    pod 'FirebaseAnalytics'
    pod 'Firebase/Database'
    pod 'Firebase/Core'
    pod 'Firebase/Storage'
    pod 'Firebase/Auth'
    pod 'Firebase/Messaging'
    
    #Crashlytics
    pod 'Fabric'
    pod 'Crashlytics'
    
    #Facebook
    pod 'FacebookCore'
    pod 'FacebookLogin'
    pod 'FacebookShare'
    pod 'AccountKit'
    
    #Keyboard
    pod 'IQKeyboardManagerSwift'
    pod 'IHKeyboardAvoiding'
    
    #Payment & Bank
    pod 'Stripe'
    pod 'BraintreeDropIn'
    pod 'CreditCardForm', :git => 'https://github.com/orazz/CreditCardForm-iOS', branch: 'master'
    pod 'PayUmoney_PnP'
    
    #Others
    pod 'lottie-ios'
    pod 'KWDrawerController'
    pod 'DateTimePicker'
    pod 'PopupDialog'
    pod 'Lightbox'
    pod 'DropDown'

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end


