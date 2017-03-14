#
#  Be sure to run `pod spec lint LLDropDownMenuSwift.podspec.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.name         = "LLDropDownMenuSwift"
s.version      = "0.0.6"
s.summary      = "下拉菜单"

s.description  = <<-DESC
一个简单易用的三级下拉菜单
DESC

s.homepage     = "https://github.com/lincoly/LLDropDownMenuSwift"
# s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


s.license      = "MIT"
# s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

s.author             = { "lincoly" => "lincoly@foxmail.com" }

# s.platform     = :ios
s.platform     = :ios, "8.0"

s.source       = { :git => "https://github.com/lincoly/LLDropDownMenuSwift.git", :tag => "#{s.version}" }


s.source_files  = "core", "core/**/*.{h,m,swift}"

s.resource_bundles = {
"LLResources" => ["core/Resources/LLResources.bundle"]
}

# s.resources = "Resources/*.png"

# ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.requires_arc = true

end
