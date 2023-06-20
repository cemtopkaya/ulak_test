require 'redmine'

Redmine::Plugin.register :my_plugin do
  name 'My Plugin'
  author 'Your Name'
  description 'A simple Redmine plugin'
  version '0.1.0'
  url 'https://your-plugin-url.com'
  author_url 'https://your-website.com'
end
