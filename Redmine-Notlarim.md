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
bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production
```

çıktısı:

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

Ve sonuç:

![image](https://github.com/cemtopkaya/redmine_plugin_1/assets/261946/f42b48dd-c46f-45d9-bf6e-eb54d68375c9)

## Kodlar

### issue_id'nin ilişkili revizyonlarının repository bilgilerini çeker

Issue sayfasında ilişkili revizyonların içinde döner ve repository_id değerlerini tekrarsız hale getirir.

```ruby
context[:issue].changesets&.map { |c| c.repository.id }.uniq.each { |repo_id| puts repo_id }
```

Repository bilgisi:

```ruby
context[:issue].changesets&.map { |c| c.repository.id }.uniq.each { |repo_id| puts Repository.find_by_id(repo_id).inspect }
#<Repository::Git id: 1, project_id: 1, url: "/home/redmine/repos/my_plugin.git", login: "", password: [FILTERED], root_url: "/home/redmine/repos/my_plugin.git", type: "Repository::Git", path_encoding: "", log_encoding: nil, extra_info: {"extra_report_last_commit"=>"0", "heads"=>["0ad57a72ec80071b94d1cf55bcd86474a736d631", "bd0da8a8de5717dd9248fcb04d3906825f507405"], "db_consistent"=>{"ordering"=>1}}, identifier: "git_identifier", is_default: true, created_on: "2023-07-01 09:56:24.000000000 +0000">
```

Aktif issue içindeki revizyonlardan hangi dizinde olduklarını bulup, ilgili commit id değerini kapsayan etiketleri bulur:

```ruby
context[:issue].changesets&.each { |cs| puts `git -C #{Repository.find_by_id(cs.repository_id).url} tag --contains #{cs.revision}` }
1.1.0-1-bd0da8a8
```

- `context[:issue].changesets&`: `&` ile varsa `changesets` değerine bakar.
- `.each { |cs|`: `changesets` içinde gez ve her birini `cs` değişkenine ata.
- `Repository.find_by_id(cs.repository_id).url`: changeset'in repository_id değerinden repository bilgisine eriş.
- `git -C #{Repository.find_by_id(cs.repository_id).url} tag --contains #{cs.revision}`: changeset'in commit id değerini içeren etiketleri getir.


# db:migrate ve Veritabanı İşlemleri

Tüm "redmine" veritabanını önce siler (`db:drop`) sonra yaratır ve güncelleme dosyalarını çalıştırır.

```shell
bundle exec rake db:drop db:create db:migrate
```

Belirli bir eklenti için `db:migrate` çalıştırılır

```shell
root@c802f15a15b8:/usr/src/redmine/plugins/my_plugin# bundle exec rake redmine:plugins:migrate NAME=my_plugin RAILS_ENV=production --trace
```

# Hook'lar

Redmine içinde hook için [geliştirici bağlantısı](https://www.redmine.org/projects/redmine/wiki/Hooks_List).

```shell
root@c802f15a15b8:/usr/src/redmine# grep -roh  'call_hook([^)]*)' /usr/src/redmine | sort -u | grep '([^)]*)'
call_hook(:"view_custom_fields_form_#{@custom_field.type.to_s.underscore}", :custom_field => @custom_field, :form => f)
call_hook(:another_hook, :foo => 'bar')
call_hook(:controller_account_success_authentication_after, {:user => user})
call_hook(:controller_custom_fields_edit_after_save, :params => params, :custom_field => @custom_field)
call_hook(:controller_custom_fields_new_after_save, :params => params, :custom_field => @custom_field)
call_hook(:controller_issues_bulk_edit_before_save, {:params => params, :issue => issue})
call_hook(:controller_issues_new_after_save, {:params => params, :issue => @issue})
call_hook(:controller_issues_new_before_save, {:params => params, :issue => @issue})
call_hook(:controller_journals_edit_post, {:journal => @journal, :params => params})
call_hook(:controller_messages_new_after_save, {:params => params, :message => @message})
call_hook(:controller_messages_reply_after_save, {:params => params, :message => @reply})
call_hook(:controller_wiki_edit_after_save, {:params => params, :page => @page})
call_hook(:some_hook)
call_hook(:view_calendars_show_bottom, :year => @year, :month => @month, :project => @project, :query => @query)
call_hook(:view_custom_fields_form_upper_box, :custom_field => @custom_field, :form => f)
call_hook(:view_issue_statuses_form, :issue_status => @issue_status)
call_hook(:view_issues_bulk_edit_details_bottom, { :issues => @issues })
call_hook(:view_issues_context_menu_end, {:issues => @issues, :can => @can, :back => @back })
call_hook(:view_issues_context_menu_start, {:issues => @issues, :can => @can, :back => @back })
call_hook(:view_issues_edit_notes_bottom, { :issue => @issue, :notes => @notes, :form => f })
call_hook(:view_issues_form_details_bottom, { :issue => @issue, :form => f })
call_hook(:view_issues_form_details_top, { :issue => @issue, :form => f })
call_hook(:view_issues_history_changeset_bottom, { :changeset => changeset })
call_hook(:view_issues_history_journal_bottom, { :journal => journal })
call_hook(:view_issues_history_time_entry_bottom, { :time_entry => time_entry })
call_hook(:view_issues_index_bottom, { :issues => @issues, :project => @project, :query => @query })
call_hook(:view_issues_new_top, {:issue => @issue})
call_hook(:view_issues_show_description_bottom, :issue => @issue)
call_hook(:view_issues_show_details_bottom, :issue => @issue)
call_hook(:view_issues_sidebar_issues_bottom)
call_hook(:view_issues_sidebar_planning_bottom)
call_hook(:view_issues_sidebar_queries_bottom)
call_hook(:view_journals_notes_form_after_notes, { :journal => @journal})
call_hook(:view_journals_update_js_bottom, { :journal => @journal })
call_hook(:view_layouts_base_html_head)
call_hook(:view_layouts_base_html_head, :foo => 1, :bar => 'a')
call_hook(:view_layouts_base_sidebar)
call_hook(:view_my_account, :user => @user, :form => f)
call_hook(:view_my_account_contextual, :user => @user)
call_hook(:view_my_account_preferences, :user => @user, :form => f)
call_hook(:view_projects_form, :project => @project, :form => f)
call_hook(:view_projects_settings_members_table_header, :project => @project)
call_hook(:view_projects_settings_members_table_row, { :project => @project, :member => member})
call_hook(:view_projects_show_left, :project => @project)
call_hook(:view_projects_show_right, :project => @project)
call_hook(:view_projects_show_sidebar_bottom, :project => @project)
call_hook(:view_projects_sidebar_queries_bottom)
call_hook(:view_reports_issue_report_split_content_left, :project => @project)
call_hook(:view_reports_issue_report_split_content_right, :project => @project)
call_hook(:view_repositories_show_contextual, { :repository => @repository, :project => @project })
call_hook(:view_search_index_options_content_bottom)
call_hook(:view_settings_general_form)
call_hook(:view_time_entries_bulk_edit_details_bottom, { :time_entries => @time_entries })
call_hook(:view_time_entries_context_menu_end, {:time_entries => @time_entries, :can => @can, :back => @back })
call_hook(:view_time_entries_context_menu_start, {:time_entries => @time_entries, :can => @can, :back => @back })
call_hook(:view_timelog_edit_form_bottom, { :time_entry => @time_entry, :form => f })
call_hook(:view_users_form, :user => @user, :form => f)
call_hook(:view_users_form_preferences, :user => @user, :form => f)
call_hook(:view_versions_show_contextual, { :version => @version, :project => @project })
call_hook(:view_welcome_index_left)
call_hook(:view_welcome_index_right)
call_hook(:view_wiki_show_sidebar_bottom, :wiki => @wiki, :page => @page)
call_hook(hook, context={})
call_hook(hook, default_context.merge(context)
```

# Eklentilerin Proje Modüllerinde Faal Edilmesi

### Proje modüllerini listele:

```ruby
Project.find(1).enabled_module_names
["issue_tracking", "time_tracking", "news", "documents", "files", "wiki", "repository", "boards", "calendar", "gantt", "git_tag_artifacts_1_0_0"]
```

```ruby
# eklentinin adı sembol olarak $NAME_CODE_ARTIFACTS global değişkeninde tutuluyor
# $NAME_CODE_ARTIFACTS = :git_tag_artifacts_1_0_0
project_id = context[:project][:id]
current_project = Project.find(project_id)
current_project.module_enabled?($NAME_CODE_ARTIFACTS)
```

# Eklenti Yetkilendirme

### Kaynaklar

- [Diving into the initialization file](https://subscription.packtpub.com/book/business-and-other/9781783288748/1/ch01lvl1sec09/diving-into-the-initialization-file)


### Modül Temelli Yetkilendirme
Her Redmine eklentisi, eklentinin başlangıçta Redmine'e kaydedilmesi için bir başlatma dosyası (init.rb) eklenmesini gerektirir.

Aşağıda bir init.rb dosyasında eklentiye dair yer alabilecek özelliklerin açıklamalarını bulabilirsiniz:

**`name`:** Bu, eklentinin tam adıdır. 
**`description`:** Bu, eklentinin ne yaptığına dair kısa bir açıklama verir. 
**`url`:** Bu, eklentinin kendisinin web sitesidir. Bu genellikle çevrimiçi veri havuzu URL'si (GitHub, Bitbucket, Google Code vb.) veya eklenti web sitesidir (varsa veya uygulanabilirse). 
**`author`:** Bu, eklentinin yazarlarının adlarını tutar. 
**`author_url`:** Bu, genellikle yazar(lar)ın e-posta adreslerine veya bloglarına bağlantıdır. 
**`version`:** Bu, eklentinin dahili sürüm numarasıdır. Zorunlu olmamakla birlikte, Redmine benzer (resmi olmasa da) bir numaralandırma şeması izlediğinden Anlamsal Sürüm Oluşturma kullanmak iyi bir uygulamadır (daha fazla bilgi için http://semver.org adresine bakın). 
**`settings`:** Bu alan, dahili eklenti ayarlarının varsayılan değerlerini tanımlamak ve ayarlamak ve sistem yöneticilerinin eklenti yapılandırma değerlerini ayarlamak için kullanabileceği kısmi bir görünüme bağlantı vermek için kullanılır.

`init.rb` Dosyasında yetkilendirme ayarlarını eklentiyi modül haline getirip oluşturuyoruz:

```ruby
  project_module $NAME_CODE_ARTIFACTS do
    # Code Artifacts sekme başlığını
    permission :view_issue_code_artifacts_tab, {}
    # Code Artifacts sekme içeriğini göster
    permission :view_issue_code_artifacts, { issue_code_artifacts: :view_issue_code_artifacts }
    # Code Artifacts etiketlerinin bilgilerini çek
    permission :get_tag_artifact_metadata, { issue_code_artifacts: :get_tag_artifact_metadata }
  end
```

`before_action :authorize, only: [ :get_tag_artifact_metadata, :view_issue_code_artifacts ]` bu kod şu demek:
Sadece (`only`) `get_tag_artifact_metadata` ve `view_issue_code_artifacts` metotlarını çalıştırmadan önce (`before_action`) Redmine ile gelen `authorize` metodunu çalıştırıp yetkilendirme yapar. Bu yetkilendirme `benim_yetkilendirmem` fonksiyonuna benzer bir iş yapar.
Bu işi kendimiz yapmak istersek `before_action :benim_yetkilendirmem, only: [ :get_tag_artifact_metadata, :view_issue_code_artifacts ]` kodunu inceleyebilirsiniz.

```ruby
class IssueCodeArtifactsController < ApplicationController
  # before_action :authorize, only: [ :get_tag_artifact_metadata, :view_issue_code_artifacts ]
  before_action :benim_yetkilendirmem, only: [ :get_tag_artifact_metadata, :view_issue_code_artifacts ]

  def benim_yetkilendirmem
    current_project = Project.find(Issue.find(params[:issue_id])[:project_id])
    unless User.current.allowed_to?(:get_tag_artifact_metadata, current_project)
      @error_message = "Kullanıcının bu bilgiye erişme yetkisi yok!"
      html_content = render_to_string(
        template: "errors/401",
        layout: false,
      )
      render html: html_content
    end
  end

  def get_tag_artifact_metadata
    puts ">>>>>>>>>> get_tag_artifact_metadata.............."
  end
end
```

```ruby
Redmine::AccessControl.permission(:view_code_artifacts)
#<Redmine::AccessControl::Permission:0x00007fb15ba99548 @name=:view_code_artifacts, @actions=["issue_code_artifacts/get_tag_artifact_metadata"], @public=false, @require=nil, @read=false, @project_module=:git_tag_artifacts_1_0_0>
```