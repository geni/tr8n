# Dual-boot compatible boot file for Rails 2.3 and 3.0
# Configure your app in config/environment.rb and config/environments/*.rb

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

# Detect if we're running under next_rails (Rails 3.0)
def rails_3?
  ENV['BUNDLE_GEMFILE'] && ENV['BUNDLE_GEMFILE'].include?('.next')
end

if rails_3?
  # Rails 3.0 boot process
  # Load individual Rails components (since we're not using the rails meta-gem)

  # Patch Rails 3.0 for Ruby 2.7 compatibility after install
  `#{RAILS_ROOT}/script/patch_rails_3_for_ruby_27.sh`

  # Monkey patch for Rails 3.0 + Ruby 2.7+ compatibility
  # Must happen BEFORE requiring active_support
  if RUBY_VERSION >= '2.7'
    require 'active_support/version'
    if ActiveSupport::VERSION::STRING =~ /^3\.0/
      # Patch the TimeZone class before it's loaded
      require 'active_support/values/time_zone'
      module ActiveSupport
        class TimeZone
          # Fix circular argument reference in parse method
          remove_method :parse if method_defined?(:parse)
          def parse(str, now_time=nil)
            now_time ||= self.now
            date_parts = Date._parse(str)
            return if date_parts.blank?
            time = Time.parse(str, now_time) rescue DateTime.parse(str)
            time.in_time_zone(self)
          end
        end
      end
    end
  end

  require 'active_support'
  require 'active_model'
  require 'active_record'
  require 'action_pack'
  require 'action_mailer'

  # Bundler setup for Rails 3.0 (but don't auto-require tr8n yet)
  if defined?(Bundler)
    # Manually require gems to avoid auto-requiring tr8n
    Bundler.setup(:default, :test) rescue Bundler.setup(:default)
  end
else
  # Rails 2.3 boot process (original code)
  module Rails
    class << self
      def boot!
        unless booted?
          preinitialize
          pick_boot.run
        end
      end

      def booted?
        defined? Rails::Initializer
      end

      def pick_boot
        (vendor_rails? ? VendorBoot : GemBoot).new
      end

      def vendor_rails?
        File.exist?("#{RAILS_ROOT}/vendor/rails")
      end

      def preinitialize
        load(preinitializer_path) if File.exist?(preinitializer_path)
      end

      def preinitializer_path
        "#{RAILS_ROOT}/config/preinitializer.rb"
      end
    end

    class Boot
      def run
        load_initializer
        Rails::Initializer.run(:set_load_path)
      end
    end

    class VendorBoot < Boot
      def load_initializer
        require "#{RAILS_ROOT}/vendor/rails/railties/lib/initializer"
        Rails::Initializer.run(:install_gem_spec_stubs)
        Rails::GemDependency.add_frozen_gem_path
      end
    end

    class GemBoot < Boot
      def load_initializer
        self.class.load_rubygems
        load_rails_gem
        require 'initializer'
      end

      def load_rails_gem
        if version = self.class.gem_version
          gem 'rails', version
        else
          gem 'rails'
        end
      rescue Gem::LoadError => load_error
        if load_error.message =~ /Could not find RubyGem rails/
          STDERR.puts %(Missing the Rails #{version} gem. Please `gem install -v=#{version} rails`, update your RAILS_GEM_VERSION setting in config/environment.rb for the Rails version you do have installed, or comment out RAILS_GEM_VERSION to use the latest version installed.)
          exit 1
        else
          raise
        end
      end

      class << self
        def rubygems_version
          Gem::VERSION
        end

        def gem_version
          if defined? RAILS_GEM_VERSION
            RAILS_GEM_VERSION
          elsif ENV.include?('RAILS_GEM_VERSION')
            ENV['RAILS_GEM_VERSION']
          else
            parse_gem_version(read_environment_rb)
          end
        end

        def load_rubygems
          min_version = '1.3.2'
          require 'rubygems'
          unless rubygems_version >= min_version
            $stderr.puts %Q(Rails requires RubyGems >= #{min_version} (you have #{rubygems_version}). Please `gem update --system` and try again.)
            exit 1
          end

        rescue LoadError
          $stderr.puts %Q(Rails requires RubyGems >= #{min_version}. Please install RubyGems and try again: http://rubygems.rubyforge.org)
          exit 1
        end

        def parse_gem_version(text)
          $1 if text =~ /^[^#]*RAILS_GEM_VERSION\s*=\s*["']([!~<>=]*\s*[\d.]+)["']/
        end

        private
          def read_environment_rb
            File.read("#{RAILS_ROOT}/config/environment.rb")
          end
      end
    end
  end

  # All that for this:
  Rails.boot!
end

require 'rbconfig'
Config = RbConfig
