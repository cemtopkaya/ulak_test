# Redmine Eklentisi Geliştirmek

Eklentiyi `/usr/src/redmine/plugins` dizininde, `git clone https://github.com/cemtopkaya/my_plugin.git` komutu ile çekebilir, `bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production` komutuyla veritabanı değişimlerini oluşturabilirsiniz.

Redmine docker içinde aşağıdaki compose.yml ile çalışıyor ve içine VS Code ile debug için bir paket `gem install ruby-debug-ide` ve eklenti kuruyoruz.

```yaml
version: '3.1'

networks:
  redmine_kiwi_network:
    driver: bridge
    ipam:
      config:
        - subnet: 20.0.2.0/24
          gateway: 20.0.2.1
    
services:
  redmine:
    build: .
    container_name: redmine_kiwi
    pull_policy: if_not_present
    image: redmine:5.0.2-custom
    restart: always
    entrypoint: "/docker-entrypoint.sh rails server -b 0.0.0.0"
    #entrypoint: "tail -f /dev/null && ./docker-entrypoint.sh rails server -b 0.0.0.0"

    networks:
      redmine_kiwi_network:

    ports:
      - 96:3000

    environment:
      REDMINE_DB_MYSQL: db
      REDMINE_DB_USERNAME: root
      REDMINE_DB_PASSWORD: admin
      REDMINE_DB_DATABASE: redmine
      REDMINE_SECRET_KEY_BASE: admin
    volumes:
      - ./volume/redmine/redmine-plugins:/usr/src/redmine/plugins
      - ./volume/redmine/repos:/home/redmine/repos ###
      - ./volume/redmine/redmine-themes:/usr/src/redmine/public/themes
      - ./volume/redmine/redmine-data:/usr/src/redmine/files
      - ./volume/redmine/redmine-logs:/usr/src/redmine/log
      - ./volume/redmine/redmine-config/configuration.yml:/usr/src/redmine/config/configuration.yml
#      - ./volume/redmine/redmine-config/additional_environment.rb:/usr/src/redmine/config/additional_environment.rb
      - ./volume/redmine/plantuml/plantuml.sh:/usr/bin/plantuml.sh:z
      - ./volume/redmine/plantuml/plantuml-1.2022.7.jar:/home/redmine/plantuml.jar:z
    depends_on:
      - db

  db:
    container_name: redmine_mysql_kiwi
    image: mysql:5.7
    restart: always
    networks:
      redmine_kiwi_network:
    environment:
      MYSQL_ROOT_PASSWORD: admin
      MYSQL_DATABASE: redmine
      MYSQL_USER: admin

    ports:
      - 3326:3306

    volumes:
      - ./volume/mysql/mysql-data:/var/lib/mysql
      - ./volume/mysql/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf
```

Yukarıdaki Redmine yansısı için aşağıdaki Dockerfile kullanılacak:

```Dockerfile
FROM redmine:5.0.2

RUN apt update && apt install -y \
    graphviz vim unzip iputils-ping htop net-tools

RUN apt install -y ubuntu-dev-tools

# libreoffice yüklenince dmsf inline editing yapabilecek
RUN apt install -y libreoffice liblibreoffice-java

# dms eklentisinin belgeleri endekleme araclari (indexing tools):
RUN apt-get install -y xapian-omega ruby-xapian libxapian-dev poppler-utils antiword  unzip catdoc libwpd-tools \
libwps-tools gzip unrtf catdvi djview djview3 uuid uuid-dev xz-utils libemail-outlook-message-perl
```

İlk redmine eklentim

# Çalışan en basit eklenti (1.0)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/86c7dc61-4bcb-4816-a03d-6efb4603f7f1)

1.0'daki kodları ve ilişkileri inceleyelim:

```ruby
# my_plugin/init.rb

require 'redmine'

Redmine::Plugin.register :my_plugin do
  name 'My Plugin'
  author 'Your Name'
  description 'A simple Redmine plugin'
  version '0.1.0'
  url 'https://your-plugin-url.com'
  author_url 'https://your-website.com'
end
```

Bu kod bloğu, eklentinin temel ayarlarını tanımlar. `name`, `author`, `description`, `version`, `url` ve `author_url` gibi alanlar eklentinin bilgilerini temsil eder.

```ruby
# my_plugin/controllers/my_controller.rb

class MyController < ApplicationController
  def index
    @message = 'Merhaba, Redmine eklentisine hoş geldiniz!'
  end
end
```

`MyController` sınıfı, eklentinin iş mantığını kontrol eden Ruby sınıfını temsil eder. `index` adında bir fonksiyon (aksiyon) tanımlanır. Bu aksiyon, eklentinin `index.html.erb` görünümünü çağırdığında çalışır. Bu aksiyon, `@message` değişkenini tanımlayarak görünüme iletecek bir mesaj içerir.

```html+erb
<!-- my_plugin/views/my/index.html.erb -->

<h2><%= @message %></h2>
```

Bu HTML ve Ruby kombinasyonu, `index` aksiyonunda tanımlanan `@message` değişkenini görünüme aktarır ve tarayıcıda görüntülenir.

```ruby
# config/routes.rb

get 'my_plugin', to: 'my#index'
```

Bu kod parçası, eklenti rotasını tanımlar. `'my_plugin'` rotası, `my_controller.rb` dosyasındaki `MyController` sınıfındaki `index` aksiyonuna yönlendirilir. Yani, tarayıcıda `http://localhost:3000/my_plugin` adresine gidildiğinde, `index` aksiyonu çalışır ve ilgili görünüm (`index.html.erb`) gösterilir.

Eklentinin nasıl çalıştığını özetlemek gerekirse:
- `init.rb` dosyası, eklentinin temel ayarlarını belirler ve Redmine'e eklentiyi kaydeder.
- `my_controller.rb` dosyası, eklentinin iş mantığını içerir. `index` aksiyonu, bir mesaj içeren `@message` değişkenini tanımlar.
- `index.html.erb` dosyası, `@message` değişkenini görüntüler.
- `routes.rb` dosyası, `my_plugin` rotasını `my_controller.rb` dosyasındaki `index` aksiyonuna yönlendirir.

Sonuç olarak, tarayıcıda `http://localhost:3000/my_plugin` adresine gidildiğinde, `MyController` sınıfındaki `index` aksiyonu çalışır ve mesaj içeren `index.html.erb` görünümü gösterilir.

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/cd657009-2d0b-44d4-a459-e3cd9cf8aa21)


# Menüye Eklentiyi Bağlantı Olarak Eklemek (2.0)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/aa3deb32-3953-4e0f-ab69-3414ceacee8a)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/ebd5bb60-e468-4c64-8dc3-462daff1edff)


```
root@9353c2bdab4a:/usr/src/redmine# bundle exec rails generate redmine_plugin_controller my_plugin denetleyici index getir gotur
      create  plugins/my_plugin/app/controllers/denetleyici_controller.rb
      create  plugins/my_plugin/app/helpers/denetleyici_helper.rb
      create  plugins/my_plugin/test/functional/denetleyici_controller_test.rb
      create  plugins/my_plugin/app/views/denetleyici/index.html.erb
      create  plugins/my_plugin/app/views/denetleyici/getir.html.erb
      create  plugins/my_plugin/app/views/denetleyici/gotur.html.erb
```

Projeler bağlantısına tıklayınca eklentinin menüde olduğunu göreceksiniz.

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/03df9553-fc6a-465b-b37a-0c9bb5a7dd5f)


# Issue sayfasına view_issues_show_details_bottom isimli hook ile Eklenti Geliştirmek (3.0)

Hook'lar, eklentinizin işlevselliğini Redmine çekirdeğine entegre etmek için kullanılır ve farklı noktalarda çalışan işlevlere izin verir. Bu sayede Redmine'in farklı bölümlerinde (örneğin, proje görünümü, issue ekranı, kullanıcı profili vb.) özelleştirmeler yapabilirsiniz.

Redmine eklentilerinde hook'ları konumlandırmak için genellikle `init.rb` veya `lib/my_plugin.rb` dosyaları kullanılır. Bu dosyalar, eklentinin başlatıldığı veya yüklenildiği zamanlarda çalışacak kodları içerir.


`lib/my_plugin.rb` dosyasında hook kullanımı şu şekildedir:

```ruby
module MyPlugin
  module Hooks
    class ViewIssuesShowDetailsBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_details_bottom,
        :partial => 'hooks/issues/view_issues_form_details_bottom',
        :layout => false
      )
    end
    class ViewIssuesShowSidebarBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_sidebar_bottom,
        :partial => 'hooks/issues/view_issues_show_sidebar_bottom',
        :layout => false
      )
    end
    
    class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_show_description_bottom,
        :partial => 'hooks/issues/view_issues_show_description_bottom',
        :layout => false
      )
    end
    
    class ViewIssuesContextMenuEndHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_issues_context_menu_end,
        :partial => 'hooks/issues/view_issues_context_menu_end',
        :layout => false
      )
    end
    
    class ViewLayoutsBaseSidebarHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_layouts_base_sidebar,
        :partial => 'hooks/layouts/view_layouts_base_sidebar',
        :layout => false
      )
    end
    
    class ViewProjectsShowSidebarBottomHook < Redmine::Hook::ViewListener
      include Redmine::I18n
      render_on(
        :view_projects_show_sidebar_bottom,
        :partial => 'hooks/projects/view_projects_show_sidebar_bottom',
        :layout => false
      )
    end
  end
end
```

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/bd340afc-d01e-4673-9bf7-cefdcf8e8639)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/8676f918-355e-4a7f-a6b7-3a38bdcd05c8)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/ad4535f9-1fa8-413c-abff-b876775aebed)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/71c64ef7-0d83-4eaf-9f22-956d4eb7d157)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/113cedf1-2167-4f82-a502-728cf384fd1f)


# Çalışan en basit eklenti (4.0)

Bir eklenti ile bu kez <HEAD> etiketine CSS ve JS dosyalarını iliştirecek şekilde issue altında "Test Results" başlıklı bir sekme oluşturuyoruz

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/dccd8f37-8af3-4a18-b9e5-cdd5ebb5f3ed)

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/5cf6eeb4-c5a9-47bf-ade7-7bba840fa943)


# Issue Form içinde select2 ile test ekleyebildiğimiz hali (5.0)

Yeni issue oluşturulurken veya düzenlenirken testler eklenip çıkarılıyor.

![image](https://github.com/cemtopkaya/my_plugin/assets/261946/c1974d2c-0f40-4e8b-b171-cde0503b51fc)

![image](https://github.com/cemtopkaya/my_plugin/assets/261946/bcf24029-3091-49f0-a28b-ec9e6909581b)

Ayrıca bir test ekleyip çıkarttığımızda journal olarak kayıtlara geçiyor

![image](https://github.com/cemtopkaya/my_plugin/assets/261946/3b7cff83-9b1c-453e-95d8-1954b1637933)

# Issue Test'lerinin Sonuçları Kiwi'den Çekilir (6.0)

![image](https://github.com/cemtopkaya/my_plugin/assets/261946/eaadf905-3f54-4862-91af-69d1e1121238)

Kod değişimlerinden üretilen paketlerin Jenkins api üzerinden kurulumları sağlandı.

![image](https://github.com/cemtopkaya/my_plugin/assets/261946/4db0e663-7112-4a68-89bd-c35cdab33f55)






