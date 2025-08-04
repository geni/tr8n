#
# Created by: GitHub Copilot using Claude Sonet 4
# Updated by: Scott Steadman
#
require 'yaml'
require 'fileutils'

module Tr8n
  class AssetBundler
    CONFIG_PATH = Engine.root.join('app/assets/javascripts/tr8n/config.yml')
    ASSETS_PATH = Engine.root.join('app/assets/javascripts/tr8n')

    def self.config
      # do not cache. This file is not expected to change often, but it can change.
      if File.exist?(CONFIG_PATH)
        YAML.load_file(CONFIG_PATH)
      else
        {}
      end
    end

    def self.bundle_assets!
      return unless File.exist?(CONFIG_PATH)

      config.each do |group, files|
        bundle_group(group, files)
      end

      Rails.logger.info "Tr8n: Asset bundles created for #{config.keys.join(', ')}"
    end

    def self.bundle_group(group, files)
      input_files = files.map do |file|
        file_path = ASSETS_PATH.join(file)
        Rails.logger.warn "Tr8n: File not found: #{file_path}" unless File.exist?(file_path)
        file_path.to_s
      end

      output_file = ASSETS_PATH.join("#{group}-compiled.js")

      command = "java -jar #{Engine.root.join('bin/compressors/google/compiler.jar')} --js #{input_files.join(' ')} --js_output_file #{output_file}"
      Kernel.spawn(command)

      Rails.logger.debug "Tr8n: Created bundle #{output_file}"
    end

    def self.watch_and_rebuild!
      return unless Rails.env.development?

      Thread.new do
        require 'listen'

        only_regex   = /\.js$|config.yml/
        ignore_regex = Regexp.new(config.keys.map { |k| "#{k}-compiled.js" }.map { |f| Regexp.escape(f) }.join('|'))
        listener = Listen.to(ASSETS_PATH.to_s, only: only_regex, ignore: ignore_regex) do |modified, added, removed|
          changed_files = (modified + added + removed)
          Rails.logger.info "Tr8n: Files changed: #{changed_files.map { |f| File.basename(f) }.join(', ')}"
          bundle_assets!
        end

        listener.start
        Rails.logger.info "Tr8n: Asset watcher started for #{ASSETS_PATH}"
      end
    end

  end # class AssetBundler
end # module Tr8n
