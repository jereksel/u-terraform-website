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

if ENV.include?('PROVIDER_SLUG')
  provider = ENV['PROVIDER_SLUG']
  logger.info("==")
  logger.info("==> See #{provider} docs at http://localhost:4567/docs/providers/#{provider}")
  logger.info("==")
end