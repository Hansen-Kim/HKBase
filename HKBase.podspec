Pod::Spec.new do |s|
  s.name     = 'HKBase'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = 'base iOS and OS X framework.'
  s.homepage = 'https://github.com/Hansen-Kim/HKBase'
  s.authors  = { 'Hansen Kim' => 'le5na81@gmail.com' }
  s.source   = { :git => 'https://github.com/Hansen-Kim/HKBase.git', :tag => s.version, :submodules => true }
  s.requires_arc = true
  
  s.public_header_files = 'HKBase/HKBase.h'
  s.source_files = 'HKBase/HKBase.h'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  
  s.subspec 'Runtime' do |ss|
    ss.source_files = 'HKBase/Runtime/*.{h,m}'
    ss.public_header_files = 'HKBase/Runtime/*.h'
  end

  s.subspec 'Model' do |ss|
    ss.dependency 'HKBase/Runtime'
    ss.source_files = 'HKBase/Model/*.{h,m}'
    ss.public_header_files = 'HKBase/Model/*.h'
  end

  s.subspec 'GCD' do |ss|
    ss.dependency 'HKBase/Model'
    ss.source_files = 'HKBase/GCD/*.{h,m}'
    ss.public_header_files = 'HKBase/GCD/*.h'
  end

  s.subspec 'RunloopSchedule' do |ss|
    ss.source_files = 'HKBase/RunloopSchedule/*.{h,m}'
    ss.public_header_files = 'HKBase/RunloopSchedule/*.h'
  end
end
