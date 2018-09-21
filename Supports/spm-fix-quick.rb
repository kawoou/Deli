require 'xcodeproj'

@project = Xcodeproj::Project.open('Deli.xcodeproj')

# QuickSpecBase
target = @project.targets.find { |target| target.to_s == 'QuickSpecBase' }
['Debug', 'Release'].each do |config|
  target.build_settings(config)['CLANG_ENABLE_MODULES'] = 'YES'
end

# Nimble
target = @project.targets.find { |target| target.to_s == 'Nimble' }
['Debug', 'Release'].each do |config|
  value = target.build_settings(config)['OTHER_SWIFT_FLAGS']
  
  if value.nil?
    target.build_settings(config)['OTHER_SWIFT_FLAGS'] = '-suppress-warnings'
  elsif value.kind_of?(Array)
    target.build_settings(config)['OTHER_SWIFT_FLAGS'] += ['-suppress-warnings']
  else
    target.build_settings(config)['OTHER_SWIFT_FLAGS'] += ' -suppress-warnings'
  end
end

@project.save