# encoding: utf-8

require "redmine"

def init
  begin
    Dir::foreach(File.join(File.dirname(__FILE__), "lib")) do |file|
      next unless /\.rb$/ =~ file
      require_dependency file
    end
  rescue LoadError => le
    puts "--- Error: init.rb içinde store.rb yüklenirken hata: #{le.message}"
  end
end

if Rails::VERSION::MAJOR >= 5
  ActiveSupport::Reloader.to_prepare do
    init
  end
elsif Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    init
  end
else
  Dispatcher.to_prepare :redmine_closed_date do
    init
  end
end

Redmine::Plugin.register :ulak_test do
  name "Ulak Test"
  author "Your Name"
  description "A simple Redmine plugin that adds custom content to the issue details page."
  version "1.0.0"
  url "https://example.com/plugin_homepage"
  author_url "https://example.com/your_website"
  requires_redmine :version_or_higher => "4.0.0"

  PLUGIN_ROOT = Pathname.new(__FILE__).join("..").realpath.to_s
  ayarlar = YAML::load(File.open(File.join(PLUGIN_ROOT + "/config", "settings.yml")))

  Setting.clear_cache
  settings :default => {
    "kiwi_url" => ayarlar["kiwi_url"],
    "rest_api_url" => ayarlar["rest_api_url"],
    "rest_api_username" => ayarlar["rest_api_username"],
    "rest_api_password" => ayarlar["rest_api_password"],
    "jenkins_url" => ayarlar["jenkins_url"],
    "jenkins_username" => ayarlar["jenkins_username"],
    "jenkins_token" => ayarlar["jenkins_token"],
    "deployment_job_path" => ayarlar["deployment_job_path"],
    "deployment_job_token" => ayarlar["deployment_job_token"],
  }, partial: "settings/ulak_test_eklenti_settings.html"

  @settings = settings

  puts settings
end
