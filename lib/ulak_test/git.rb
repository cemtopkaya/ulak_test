module UlakTest
  module Git

    # Bir kod revizyonunun dahil olduğu etiketleri çeker
    def self.commit_tags(git_dir, revision)
      # parametreler geçerli mi kontrol et

      git_tag_command = "git -C #{git_dir} tag --contains #{revision}"
      puts ">>>> git_tag_command: #{git_tag_command}"

      # Komutu çalıştırın ve çıktıyı yakalayın
      git_tags_output = `#{git_tag_command}`

      # Etiketleri alın
      tags = git_tags_output.split("\n")

      tag_info = []

      tags.each do |tag|
        tag_date = `git -C #{git_dir} show --format=%ai --no-patch #{tag} | grep -oP '\\d{4}-\\d{2}-\\d{2} \\d{2}\:\\d{2}\:\\d{2}'`.chomp
        tag_info << { tag: tag, date: tag_date }
      end
      
      tag_info
    end

    def self.tag_artifacts_metadata(repository_url, tag)
      result = nil
      
      git_cat_command = "git -C #{repository_url} cat-file -p #{tag}"
      puts ">>>> git_cat_command: #{git_cat_command}"
      git_cat_output = `#{git_cat_command}`

      if git_cat_output.empty?
        return nil
      end

      begin
        # İlk boş satırdan sonraki kısmı alıyoruz
        yaml_part = git_cat_output.lines.drop_while { |line| line.strip != "" }.join

        # YAML'i Ruby nesnesine çeviriyoruz
        ruby_object = YAML.safe_load(yaml_part)

        # Ruby nesnesini kullanabiliriz
        if ruby_object["distros"].present?
          # Artifacts hashini oluşturup revisions listesine ekleyin
          result = ruby_object
        end
      rescue Psych::SyntaxError => e
        # Eğer YAML formatında bir hata varsa burada işleyebiliriz
        puts "<<<<<< YAML formatında hata: #{e.message}"
      end

      result
    end

    def self.tag_artifacts(repository_url, tag)
      artifacts_metadata = tag_artifacts_metadata(repository_url, tag)
      artifacts = artifacts_metadata&.dig("distros")&.map { |cs| cs["artifacts"] }&.compact&.flatten || []
      artifacts
    end
    
    # Bir issue'nun changesets özelliği parametre olarak verilir ve her revizyon için artifacts döner

    # @param [Array<Changeset>] Changeset dizisi
    # @return [Array<String>] Artifact'lerin metin dizisini döner
    def self.commit_artifacts(changesets)
      result = []
      changesets&.each do |cs|
        get_commit_artifacs(cs)
      end

    end

    # issue İle ilişkili commitlerin varsa git etiketlerini ruby nesnesi olarak döner

    # @param [Issue] issue bilgisi
    # @return [Array]Changeset etiketlerinin açıklama YAML dosyalarını nesne dizisi olarak döner
    def self.findTagsOfCommits(changesets)
      result = []
      changesets&.each do |cs|
        # Çalıştırılacak komutu hazırlayın
        # git_tag_command = "git -C #{Repository.find_by_id(cs.repository_id).url} tag --contains #{cs.revision}"
        isMergeTags = false
        merge_tags = isMergeTags ? "--merged" : ""
        git_tag_command = "git -C #{cs.repository.url} tag #{merge_tags} --contains #{cs.revision} "
        puts ">>>> git_tag_command: #{git_tag_command}"

        # Komutu çalıştırın ve çıktıyı yakalayın
        git_tags_output = `#{git_tag_command}`

        # Etiketleri alın
        tags = git_tags_output.split("\n")

        # Her etiket için açıklamayı alın ve eşleşen etiketleri yazdırın
        tags.each do |tag|
          # Etiket açıklamasını almak için `git show` komutunu kullanın
          # git_show_command = "git -C #{Repository.find_by_id(cs.repository_id).url} show #{tag}"
          # git_show_command = "git -C #{cs.repository.url} show #{tag}"
          git_cat_command = "git -C #{cs.repository.url} cat-file -p #{tag}"
          puts ">>>> git_cat_command: #{git_cat_command}"
          git_cat_output = `#{git_cat_command}`

          # Eğer etiket varsa açıklamayı alın, yoksa "No description" yazın
          description = git_cat_output.empty? ? "No description" : git_cat_output

          begin
            # İlk boş satırdan sonraki kısmı alıyoruz
            # puts ">>>> description: #{description}"
            yaml_part = description.lines.drop_while { |line| line.strip != "" }.join

            # YAML'i Ruby nesnesine çeviriyoruz
            ruby_object = YAML.safe_load(yaml_part)

            # Ruby nesnesini kullanabiliriz
            if ruby_object["distros"].present?
              # Artifacts hashini oluşturup revisions listesine ekleyin
              artifacts = ruby_object
              result << { changeset: cs, artifacts_metadata: artifacts, artifacts: artifacts["distros"].flat_map { |distro| distro["artifacts"] } }
            else
              result << { changeset: cs, artifacts_metadata: nil, artifacts: nil }
            end
          rescue Psych::SyntaxError => e
            # Eğer YAML formatında bir hata varsa burada işleyebiliriz
            puts "<<<<<< YAML formatında hata: #{e.message}"
          end
        end # < tags.each
      end # < issue.changesets&.each
      result
    end

    
  end
end
