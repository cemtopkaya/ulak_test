#  Rails'in varsayılan davranışları hakkında başlıklar ve açıklamalar

## Tablo Adları
   - Başlık: Tekil Tablo Adları
   - Açıklama: Rails, ilişkili modellerin tablo adlarını oluştururken, genellikle tekil isimlere çoğul ek ekler. Örneğin, `Issue` modeli için ilişkili tablo adı `issues` olur.

## Model Adları:
   - Başlık: Tekil Model Adları
   - Açıklama: Rails, model isimlerini tekil olarak kabul eder. Örneğin, `Issue` modeli için tekil model adı `Issue` olur.

## İlişkili Tablo Adları:
   - Başlık: Çoğul İlişkili Tablo Adları
   - Açıklama: Rails, ilişkili tabloların çoğunlukla birçok örneğini içerdiği durumlarda çoğul tablo adlarını kullanır. Örneğin, `Issue` modeli için ilişkili tablo adı `issues` olur.

## İlişkili Model Adları:
   - Başlık: Çoğul İlişkili Model Adları
   - Açıklama: Rails, ilişkili modellerin çoğunlukla birçok örneğini içeren ilişkili tablolar için çoğul model adlarını kullanır. Örneğin, `:issues` ifadesi, ilişkili tabloyu doğru şekilde temsil eder.

Bu davranışlar, Rails'in birçok projede kullanılan yaygın kabulleri ve sözleşmeleridir. Bunlar, Rails'in kendi varsayılanlarını takip eden ve geliştiriciler arasında tutarlılık sağlayan bir yapı sunmasını sağlar. Ancak, ihtiyaçlarınıza göre bu davranışları değiştirebilir ve özelleştirebilirsiniz.


# Veritabanı Güncellemeleri ve Migration

1. Dizin Yolu

Öncelikle veritabanı işelmleri için dizin yolu şöyle olacak: `.../plugins/my_plugin/db/migrate`

2. Dosya Adları

Bu dizin içindeki `.rb` uzantılı modelin kod dosyaları (migration dosyanızın) adının standart formatta olması gerekiyor. Migration dosyalarının adı, genellikle tarih ve saat bilgisini içeren bir formatı takip etmelidir.

Örneğinizde migration dosyasının adı "CreateTestsAndIssueTestsTables" olarak belirtilmiş. Ancak, migration dosyalarının adı genellikle tarih ve saat bilgisini içeren bir formatı takip eder. Bu sayede sıralama ve takip kolaylaşır.

Yani, eklentinizin `db/migrate` dizininde bir migration dosyasının adı, genellikle `YYYYMMDDHHMMSS_create_table_name.rb` formatında olmalıdır.

Burada "20230627140000" tarih ve saat bilgisini temsil eder. Böylece migration dosyası, tarih ve saat bilgisine göre sıralanır ve daha öngörülebilir bir şekilde işlenir.

Aşağıdaki kodun içerisinde  `puts "...."` komutuyla migration dosyanızın işlendiğini konsol çıktılarında takip edebileceksiniz.

```ruby
# 20230627140000_create_tests_and_issue_tests_tables.rb

class CreateTestsAndIssueTestsTables < ActiveRecord::Migration[5.2]
  def change
    puts "Running migration: CreateTestsAndIssueTestsTables"

    create_table :tests do |t|
      t.string :test_name
      t.integer :product_id
      t.timestamp :create_date
      t.timestamp :last_retrieve_date
      t.timestamps
    end

    create_table :issue_tests do |t|
      t.references :issue, index: true
      t.references :test, index: true
      t.timestamps
    end
  end
end
```

Değişikliklerinizi aktif hale getirmeden önce veritabanına erişilebilir olması için `/usr/src/redmine/config/database.yml` dosyasının olduğundan ve `RAILS_ENV` parametresine gelebilecek `production` veya `development` değerlerini alacak şekilde veritabanı ayarlarının olduğundan emin olmalısınız.

```yaml
production:
  adapter: mysql2
  database: redmine
  host: db
  username: root
  password: admin
  # Use "utf8" instead of "utfmb4" for MySQL prior to 5.7.7
  encoding: utf8mb4

development:
  adapter: mysql2
  database: redmine_development
  host: localhost
  username: root
  password: ""
  # Use "utf8" instead of "utfmb4" for MySQL prior to 5.7.7
  encoding: utf8mb4
```

Migration dosyasının adını yukarıdaki gibi güncelledikten sonra, `bundle exec rake redmine:plugins:migrate` komutunu çalıştırarak tüm migration dosyalarını yeniden çalıştırabilirsiniz. 

Bu komutu daha özelleştirerek `bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production` doğrudan `my_plugin` eklentinizi ortamınız `production` olacak şekilde çalıştırabilirsiniz.

Konsol çıktınız şöyle olacak:
```shell
root@25794971d4b4:/usr/src/redmine# bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production
W, [2023-06-27T13:44:17.862965 #48710]  WARN -- : Creating scope :system. Overwriting existing method Enumeration.system.
W, [2023-06-27T13:44:17.966598 #48710]  WARN -- : Creating scope :sorted. Overwriting existing method User.sorted.
W, [2023-06-27T13:44:18.292549 #48710]  WARN -- : Creating scope :visible. Overwriting existing method Principal.visible.
I, [2023-06-27T13:44:19.367760 #48710]  INFO -- : Migrating to CreateTestsAndIssueTestsTables (20230627140000)
== 20230627140000 CreateTestsAndIssueTestsTables: migrating ===================
Running migration: CreateTestsAndIssueTestsTables
-- create_table(:tests)
   -> 0.0855s
-- create_table(:issue_tests)
   -> 0.0668s
== 20230627140000 CreateTestsAndIssueTestsTables: migrated (0.1526s) ==========
```

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/06efa830-e09b-44c9-a630-939eb9125cc7)



```ruby
    create_table :issue_tests do |t|
      t.references :issue, index: true
      t.references :test, index: true
      t.timestamps
    end
```
![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/6a16bf14-056c-470e-aecd-ccf3eeed7c5c)

```ruby
    create_table :tests do |t|
      t.string :test_name
      t.integer :product_id
      t.timestamp :create_date
      t.timestamp :last_retrieve_date
      t.timestamps
    end
```
![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/728cbb5a-565d-430f-8a7d-b64178562819)

Anlaşılan `create_date` ve `last_retrieve_date` alanlarına `t.timestamps` sayesinde gerek kalmıyor. Çünkü otomatik olarak `created_at` ve `updated_at` alanlarını otomatik ekliyor. 

O halde gereksiz alanları kaldırmak için bir migration dosyası daha ekleyelim.

```ruby
# my_plugin/db/migrate/20230701090000_remove_columns_from_tests.rb

class RemoveColumnsFromTests < ActiveRecord::Migration[5.2]
    def up
      remove_column :tests, :create_date
      remove_column :tests, :last_retrieve_date
    end
  
    def down
      add_column :tests, :create_date, :timestamp
      add_column :tests, :last_retrieve_date, :timestamp
    end
  end
```

Ve çalıştıralım:

```shell
root@25794971d4b4:/usr/src/redmine/plugins/my_plugin# bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production
(in /usr/src/redmine)
W, [2023-06-27T18:36:21.012906 #107304]  WARN -- : Creating scope :system. Overwriting existing method Enumeration.system.
W, [2023-06-27T18:36:21.115684 #107304]  WARN -- : Creating scope :sorted. Overwriting existing method User.sorted.
W, [2023-06-27T18:36:21.436836 #107304]  WARN -- : Creating scope :visible. Overwriting existing method Principal.visible.
I, [2023-06-27T18:36:22.470574 #107304]  INFO -- : Migrating to RemoveColumnsFromTests (20230701090000)
== 20230701090000 RemoveColumnsFromTests: migrating ===========================
-- remove_column(:tests, :create_date)
   -> 0.0773s
-- remove_column(:tests, :last_retrieve_date)
   -> 0.1296s
== 20230701090000 RemoveColumnsFromTests: migrated (0.2071s) ==================
```