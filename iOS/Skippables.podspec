Pod::Spec.new do |s|
  s.name                = "Skippables"
  s.version             = "1.0.0"
  s.summary             = "Your most efficient advertising campaign"
  s.description         = <<-DESC
  Create the most engaging invite to your brand or Upload your own compelling video ad. 
                            DESC
  s.homepage            = "https://www.skippables.com/"
  s.license             = { :type => "Copyright", :text => "Copyright 2018 Mobiblocks. All rights reserved." }
  s.author              = { "dr-mobiblocks" => "daniel.rusu@mobiblocks.com" }
  s.platform            = :ios, "9.0"
  s.source              = { :http => "http://10.0.0.50/sdk/ios/SKIPPABLES.1.0.0.zip" }
  s.source_files        = "SKIPPABLES.framework/Headers/*.{h}"
  s.preserve_paths      = "SKIPPABLES.framework/*"
  s.vendored_frameworks = 'SKIPPABLES.framework'
  s.frameworks          = "CoreGraphics", "AdSupport", "CoreTelephony", "SystemConfiguration", "AVKit"

end
