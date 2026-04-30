require 'rubygems'

# Apply Rails 3.2 patches for Ruby 2.7+ compatibility before loading Rails
patch_script = File.expand_path('../../../../script/patch_rails_3_2_for_ruby_27.rb', __FILE__)
if File.exist?(patch_script)
  load patch_script
else
  warn "Warning: Rails 3.2 patch script not found at #{patch_script}"
end

gemfile = File.expand_path('../../../../Gemfile', __FILE__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$:.unshift File.expand_path('../../../../lib', __FILE__)