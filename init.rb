# encoding: utf-8

require "redmine"

$NAME_KIWI_TESTS = :kiwi_test
$PLUGIN_NAME_KIWI_TESTS = :plugin_kiwi_test

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

#Redmine::Plugin.remove_plugin('ulak_test')

Redmine::Plugin.register :kiwi_test do
  name "Ulak Test"
  author "Cem Topkaya"
  description "Kiwi TCMS integration for Redmine"
  version "1.0.0"
  url "https://github.com/cemtopkaya/ulak_test"
  author_url "https://cemtopkaya.com"
  requires_redmine :version_or_higher => "5.0.0"

  PLUGIN_ROOT_KIWI_TESTS = Pathname.new(__FILE__).join("..").realpath.to_s
   yaml_settings = YAML::load(File.open(File.join(PLUGIN_ROOT_KIWI_TESTS + "/config", "settings.yml")))

  settings :default => {
    "kiwi_url" => yaml_settings["kiwi_url"],
    "rest_api_url" => yaml_settings["rest_api_url"],
    "rest_api_username" => yaml_settings["rest_api_username"],
    "rest_api_password" => yaml_settings["rest_api_password"],
  }, partial: "settings/ulak_test_eklenti_settings.html"

end
