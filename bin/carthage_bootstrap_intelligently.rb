require 'xcodeproj'

if __FILE__ == $0
  project_path = 'allegro.xcodeproj'
  project = Xcodeproj::Project.open(project_path)
  built_framework_objects = project['allegro/Frameworks'].files.map { |f| f.path }
  missing = built_framework_objects.keep_if { |f| not File.exist?(f) }
  framework_names = missing.map { |f| Pathname.new(f).basename('.framework') }
  if framework_names.empty?
    puts "\n"
    puts "Carthage dependencies are up to date"
    puts "\n"
  else
    puts "\n"
    puts "missing: #{framework_names.join(', ')}"
    puts "running `carthage bootstrap #{framework_names.join(' ')}`"
    puts `carthage bootstrap #{framework_names.join(' ')}`
    puts "\n"
  end
end
