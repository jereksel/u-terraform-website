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

# For Github pages: https://stackoverflow.com/a/23443761
set :relative_links, true