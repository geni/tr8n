namespace :tr8n do

  desc "Bundle TR8N JavaScript assets"
  task :bundle_assets => :environment do
    Tr8n::AssetBundler.bundle_assets!
    puts "Tr8n assets bundled successfully!"
  end

end
