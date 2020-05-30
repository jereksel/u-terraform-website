set :base_url, "https://www.terraform.io/"

activate :hashicorp do |h|
  h.name        = "terraform"
  h.version     = "0.12.26"
  h.github_slug = "hashicorp/terraform"
  h.releases_enabled = false
  h.minify_javascript = false
end

ignore "ext/**/*"
config[:file_watcher_ignore] += [/^(\/website\/)?ext\//]

require "middleman_helpers"
require "base_path_extension"
helpers Helpers

rewrites = ["intro/index.html", "community.html", "docs/providers/index.html"]

rewrites.each do |url|
    redirect url, to: "https://terraform.io/#{url}"
end

if not ENV.include?('PROVIDER_SLUG')
  raise "Environmental variable PROVIDER_SLUG must be set"
end

provider = ENV['PROVIDER_SLUG']
redirect "index.html", to: "docs/providers/#{provider}"

::Middleman::Extensions.register(:fix_base_path, FixBasePath)


if ENV.include?('BASE_PATH')
  base_url = ENV['BASE_PATH']
  activate :fix_base_path, base_path: base_url
  set :base_url, base_url
else
  activate :fix_base_path, base_path: ""
end

# For GitHub Pages:
activate :relative_assets
set :relative_links, true
