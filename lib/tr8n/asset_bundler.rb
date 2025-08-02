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
      @config ||= if File.exist?(CONFIG_PATH)
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
      content = files.map do |file|
        file_path = ASSETS_PATH.join(file)

        if File.exist?(file_path)
          File.read(file_path)
        else
          Rails.logger.warn "Tr8n: File not found: #{file_path}"
          "// Tr8n::AssetBundler File not found: #{file}"
        end
      end.join("\n\n")

      output_file = ASSETS_PATH.join("#{group}.js")
      File.write(output_file, content)

      Rails.logger.debug "Tr8n: Created bundle #{output_file}"
    end

    def self.watch_and_rebuild!
      return unless Rails.env.development?

      Thread.new do
        require 'listen'

        only_regex   = /\.js$|config.yml/
        ignore_regex = Regexp.new(config.keys.map { |k| "#{k}.js" }.map { |f| Regexp.escape(f) }.join('|'))
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
