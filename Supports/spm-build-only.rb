require 'xcodeproj'

@project = Xcodeproj::Project.open('Deli.xcodeproj')

# Target
target = @project.targets.find { |target| target.to_s == 'Deli' }

# Scheme
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.save_as(@project.path, 'Deli-Only')

@project.save