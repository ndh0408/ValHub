# Registers ios/Runner/<lproj>/InfoPlist.strings with the Xcode project so the
# localized permission prompts ship in the bundle (docs/design/I18N.md 11.5).
#
#   ruby tool/ios_localizations.rb      (macOS; needs the xcodeproj gem,
#                                        which CocoaPods installs)
#
# Idempotent: re-running adds only new languages.
require 'xcodeproj'

root = File.expand_path('..', __dir__)
project = Xcodeproj::Project.open(File.join(root, 'ios', 'Runner.xcodeproj'))
target = project.targets.find { |t| t.name == 'Runner' } or abort('no Runner target')
group = project.main_group['Runner'] or abort('no Runner group')

langs = Dir[File.join(root, 'ios', 'Runner', '*.lproj', 'InfoPlist.strings')]
        .map { |p| File.basename(File.dirname(p), '.lproj') }
        .sort
abort('no InfoPlist.strings found') if langs.empty?

variant = group.children.find do |c|
  c.isa == 'PBXVariantGroup' && c.name == 'InfoPlist.strings'
end
unless variant
  variant = project.new(Xcodeproj::Project::Object::PBXVariantGroup)
  variant.name = 'InfoPlist.strings'
  variant.source_tree = '<group>'
  group.children << variant
  target.resources_build_phase.add_file_reference(variant)
end

langs.each do |lang|
  path = "#{lang}.lproj/InfoPlist.strings"
  next if variant.children.any? { |f| f.path == path }
  ref = project.new(Xcodeproj::Project::Object::PBXFileReference)
  ref.name = lang
  ref.path = path
  ref.last_known_file_type = 'text.plist.strings'
  ref.source_tree = '<group>'
  variant.children << ref
end

regions = project.root_object.known_regions
(langs + ['Base']).each { |l| regions << l unless regions.include?(l) }
project.root_object.development_region = 'en'
project.save
puts "InfoPlist.strings: #{langs.join(', ')}"
