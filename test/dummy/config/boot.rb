# Apply Rails 3.2 patches for Ruby 2.7+ compatibility before loading Rails
patch_script = File.expand_path('../../../../script/patch_rails_3_2_for_ruby_27.rb', __FILE__)
if File.exist?(patch_script)
  load patch_script
else
  warn "Warning: Rails 3.2 patch script not found at #{patch_script}"
end

# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])
$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
