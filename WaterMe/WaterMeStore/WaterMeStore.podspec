
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "WaterMeStore"
  s.version      = "1.0.0"
  s.summary      = "WaterMe StoreKit Components."
  s.description  = "WaterMe StoreKit Components."
  s.homepage     = "www.saturdayapps.com"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = "GPLv3"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "jeffreybergier" => "jeffburg@jeffburg.com" }
  s.social_media_url   = "http://twitter.com/jeffburg"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "11.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/jeffreybergier/WaterMe2.git", :tag => "#{s.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = "Source/**/*.{h,m,swift}"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.dependency 'XCGLogger'
  s.dependency 'Result'


end
