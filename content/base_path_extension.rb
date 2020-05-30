class FixBasePath < Middleman::Extension

  # All the options for this extension
  option :base_path, "", 'Sets base path'

  def after_build(builder)
    fix_css(builder)
    fix_html(builder)
  end

  def fix_css(builder)

    css_dir = File.join(app.config[:build_dir], app.config[:css_dir])
    prefix = app.config[:build_dir] + File::SEPARATOR
    css_files = Dir.entries(css_dir).reject { |f| File.directory? f }.map{ |f| File.absolute_path File.join(css_dir, f) }

    css_files.each do |file|
      data = File.read(file)
      new_data = data.gsub("url(\"/assets", "url(\"/#{options.base_path}/assets")
      File.open(file, "w") do |f|
        f.write(new_data)
      end
      builder.say_status :fixed_css, file.sub(prefix, "")
    end

  end

  def fix_html(builder)

    prefix = app.config[:build_dir] + File::SEPARATOR
    html_files = Dir["#{app.config[:build_dir]}/**/*.html"].map{ |f| File.absolute_path f }

    html_files.each do |file|

      data = File.read(file)
      new_data = data.gsub("<a href=\"/docs/", "<a href=\"/#{options.base_path}/docs/")
      File.open(file, "w") do |f|
        f.write(new_data)
      end
      builder.say_status :fixed_html, file.sub(prefix, "")
    end

  end
end