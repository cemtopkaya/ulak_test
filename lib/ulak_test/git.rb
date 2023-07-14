module UlakTest
  module Git

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
