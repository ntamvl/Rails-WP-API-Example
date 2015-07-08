class PostMeta < ActiveRecord::Base
  self.table_name = "wp_postmeta"
  RESOURCE_IMAGE_DOMAIN = "http://resource.cartoon2watch.com/resources/images/"

  belongs_to :post, :foreign_key => :post_id

  def self.update_cover
    list_meta = PostMeta.where(meta_key: ["cover_url", "poster_url"])
    list_meta.each_with_index do |meta, index|
      puts "#{index} - checking..."
      ext = "#{File.extname(meta[:meta_value])}"
      if !ext.present?
        meta[:meta_value] = "#{meta[:meta_value]}.jpg"
        meta.save
        puts "#{meta[:id]} - #{meta[:meta_key]} - #{meta[:meta_value]}"
      end
    end
  end

  def self.check_url_valid
    list_meta = PostMeta.where(meta_key: ["cover_url", "poster_url"])
    count = 0
    list_meta.each_with_index do |meta, index|
      if meta[:meta_value].split("/").last.include? ":"
        list_post = Post.where(:id => meta[:post_id])
        if list_post.count > 0
          post = list_post.first

          movie_list = Movie.where("title LIKE ?", post[:post_title])
          if movie_list.count > 0
            movie = movie_list.first

            puts "[#{count}] -----------------------------------------------------------------"
            # download image
            image_file_name = Post.download_image(movie[:cover], movie[:title], "download/image_fixed/")
            poster_url = "#{RESOURCE_IMAGE_DOMAIN}#{image_file_name}".gsub(":", "_")

            puts "Start saving meta #{meta[:meta_id]}... "
            meta[:meta_value] = poster_url
            meta.save
            puts "Compeleted saving meta!"
            # Post.update_post_tvshow_meta(meta[:post_id], meta[:id], "poster_url", poster_url)
            # Post.update_post_tvshow_meta(meta[:post_id], meta[:id], "cover_url", poster_url)

            puts "Updated completed with #{poster_url}"
            puts "  "

            count = count + 1
          end
        end
        # puts "#{meta[:id]} - #{meta[:meta_key]} - #{meta[:meta_value]}"
        # count = count + 1
        # puts "Count is #{count}"
      end
    end
  end

end
