Pod::Spec.new do |s|
  s.name         = "DHWebViewController"             #名称
  s.version      = "0.0.4"              #版本号
  s.summary      = "webView加载框架"       #简短介绍
  s.description  = <<-DESC
                      WKWebView加载控制器
                   DESC

  s.homepage     = "http://github.com/iLMagic/DHWebViewController.git"
  # s.screenshots  = "www.example.com/screenshots_1.gif"
  s.license      = "MIT"                #开源协议
  s.author             = { "DH" => "DH_xiaoxiao@yahoo.com.hk" }

  s.source       = { :git => "https://github.com/iLMagic/DHWebViewController.git", :tag => s.version }
  ## 这里不支持ssh的地址，只支持HTTP和HTTPS，最好使用HTTPS
  ## 正常情况下我们会使用稳定的tag版本来访问，如果是在开发测试的时候，不需要发布release版本，直接指向git地址使用
  ## 待测试通过完成后我们再发布指定release版本，使用如下方式
  #s.source       = { :git => "http://EXAMPLE/O2View.git", :tag => version }
  
  s.platform     = :ios, "9.0"          #支持的平台及版本，这里我们呢用swift，直接上9.0
  s.requires_arc = true                 #是否使用ARC

  # s.prefix_header_contents = '#import <UIKit/UIKit.h>', '#import <WebKit/WebKit.h>'

  s.source_files  = "DHWebViewController/*.{h,m}", "DHWebViewController/Animator/*.{h,m}"    #OC可以使用类似这样"Classes/**/*.{h,m}"
  # s.source_files  = "DHWebViewController/Animator/*.{h,m}"    #OC可以使用类似这样"Classes/**/*.{h,m}"

  s.frameworks = "UIKit", "Foundation", "WebKit"
  s.module_name = 'DHWebViewController'              #模块名称
  # s.resource_bundles = {
  	# 'image' => ['DHSideslip/image']
  # }
  s.resources = 'DHWebViewController/image.bundle'
  s.dependency "Masonry"    #依赖关系，该项目所依赖的其他库，如果有多个可以写多个 s.dependency


#  pod trunk push DHSideslip.podspec --allow-warnings 用于升级pod库后的更新

end
