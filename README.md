# redmine_plugin_1

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
