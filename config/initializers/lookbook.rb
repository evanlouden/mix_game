if Rails.env.development?
  Lookbook.configure do |config|
    config.preview_paths = [ Rails.root.join("spec/components/previews").to_s ]
    # config.preview_layout = "lookbook"
    config.auto_refresh
  end

  Rails.application.config.to_prepare do
    Dir[Rails.root.join("spec/components/previews/*_preview.rb")].sort.each do |preview_file|
      require_dependency preview_file
    end
  end
end
