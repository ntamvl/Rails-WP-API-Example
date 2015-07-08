require 'httparty'
require 'json'
require 'open-uri'
require 'uri'

class Post < ActiveRecord::Base
  self.table_name = "wp_posts"
  has_many :post_metas, :foreign_key => :post_id

  API_URL = 'http://www.cartoon2watch.com/wp-json'
  API_POST_URL = 'http://www.cartoon2watch.com/wp-json/posts'
  BASIC_AUTH = {:username => "tamnguyen", :password => "nguyen"}
  POST_TYPE = {tvshows: "tvshows", episode: "episodios"}
  RESOURCE_IMAGE_DOMAIN = "http://resource.cartoon2watch.com/resources/images/"

  def self.create_multi_posts
  	page = 0 # [0]
  	limit = 2 # [2]
  	offset = page + limit
    # list_movie = Movie.limit(limit).offset(offset)
    list_movie = Movie.all
    list_movie.each do |movie|
      # str.strip.downcase.gsub(/\s+/," ").gsub(" ","-")
      returned_movie = Post.create_post_tvshow(movie, "post")

      # download image
      image_url = Post.download_image(movie["cover"], movie["title"])
      poster_url = "#{RESOURCE_IMAGE_DOMAIN}#{image_url}"

      Post.create_post_tvshow_meta(returned_movie["ID"], "poster_url", poster_url)
      Post.create_post_tvshow_meta(returned_movie["ID"], "cover_url", poster_url)

      Post.create_post_tvshow_meta(returned_movie["ID"], "seasons", "1")
      Post.create_post_tvshow_meta(returned_movie["ID"], "_seasons", "field_551980b8a65b5")
      Post.create_post_tvshow_meta(returned_movie["ID"], "seasons_0_episode", "#{movie.videos.count}")
      Post.create_post_tvshow_meta(returned_movie["ID"], "_seasons_0_episode", "field_551980eaa65b6")


      movie.videos.each_with_index do |video, index|
        returned_video = Post.create_video_tvshow(video)
        Post.create_post_tvshow_meta(returned_video["ID"], "ddw", "0")
        Post.create_post_tvshow_meta(returned_video["ID"], "_ddw", "field_54fa4e8cbca22")
        Post.create_post_tvshow_meta(returned_video["ID"], "voo", "0")
        Post.create_post_tvshow_meta(returned_video["ID"], "_voo", "field_54fa4f41bca28")
        Post.create_post_tvshow_meta(returned_video["ID"], "titulo_serie", "")
        Post.create_post_tvshow_meta(returned_video["ID"], "url_serie", "")
        Post.create_post_tvshow_meta(returned_video["ID"], "fecha_serie", "")
        Post.create_post_tvshow_meta(returned_video["ID"], "temporada_serie", "0")
        Post.create_post_tvshow_meta(returned_video["ID"], "episodio_serie", "#{index + 1}")

        # meta_video_poster_url = Post.create_post_tvshow_meta(returned_video["ID"], "poster_url", movie["cover"])
        # meta_video_cover_url = Post.create_post_tvshow_meta(returned_video["ID"], "cover_url", movie["cover"])

        Post.create_post_tvshow_meta(returned_video["ID"], "tvplayer", "1")
        Post.create_post_tvshow_meta(returned_video["ID"], "_tvplayer", "field_551ae27f3a233")
        Post.create_post_tvshow_meta(returned_video["ID"], "tvplayer_0_title_tvplayer", "Server 1")
        Post.create_post_tvshow_meta(returned_video["ID"], "_tvplayer_0_title_tvplayer", "field_551ae2a03a234")
        Post.create_post_tvshow_meta(returned_video["ID"], "tvplayer_0_embed_tvplayer", "#{video[:data]}")
        Post.create_post_tvshow_meta(returned_video["ID"], "_tvplayer_0_embed_tvplayer", "field_551ae2af3a235")

        Post.create_post_tvshow_meta(returned_movie["ID"], "seasons_0_episode_#{index}_url_tvshows", video[:slug].gsub("/",""))
        Post.create_post_tvshow_meta(returned_movie["ID"], "_seasons_0_episode_#{index}_url_tvshows", "field_55198102a65b7")
        Post.create_post_tvshow_meta(returned_movie["ID"], "seasons_0_episode_#{index}_runtime_tvshows", "")
        Post.create_post_tvshow_meta(returned_movie["ID"], "_seasons_0_episode_#{index}_runtime_tvshows", "")

      end
    end
  end

  def self.create_post_tvshow(m_movie, m_type = "tvshows")
    puts "Creating a post, type is #{m_type}..."
    post_body = {
      :title => m_movie[:title],
      :content_raw => m_movie[:summary],
      :excerpt_raw => m_movie[:other_title],
      :name => m_movie[:title],
      :type => m_type,
      :status => 'publish',
      :term => m_movie.movie_category[:title].downcase.strip.gsub(/\s+/," ").gsub(" ","-"),
      :tax => "category",
    }
    post_return = HTTParty.post(
      "#{API_POST_URL}",
      :body => post_body.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    puts "post_return is #{post_return}"
    return post_return
  end

  def self.create_video_tvshow(m_video, m_type = "episodios")
    puts "Creating a episodios..."
    post_body = {
      :title => m_video[:title],
      :content_raw => m_video[:title],
      :excerpt_raw => m_video[:title],
      :name => m_video[:slug].gsub("/", ""),
      :type => m_type,
      :status => 'publish'
    }
    post_return = HTTParty.post(
      "#{API_POST_URL}",
      :body => post_body.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )

    puts "post_return is #{post_return}"
    return post_return
  end

  def self.create_post_tvshow_meta(post_id, meta_key, meta_value)
    puts "Creating a meta for post #{post_id}..."
    result_meta = HTTParty.post(
      "#{API_POST_URL}/#{post_id}/meta",
      :body => {
        :key => "#{meta_key}",
        :value => meta_value.present? ? meta_value.gsub("\"","") : meta_value
      }.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    puts "result for post #{post_id} is #{result_meta}"
  end

  def self.update_post_tvshow_meta(post_id, meta_id,  meta_key, meta_value)
    puts "Updating a meta for post #{post_id}..."
    result_meta = HTTParty.post(
      "#{API_POST_URL}/#{post_id}/meta/#{meta_id}",
      :body => {:key => "#{meta_key}",:value => meta_value.gsub("\"","")}.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    puts "result for post #{post_id} is #{result_meta}"
  end

  def self.download_image(image_url, prefix = "", path = "download/images/")
    # get filename
    # image_url = 'http://www.example.com/foo/bar/filename.jpg?2384973948743'
    puts "Start downloading #{image_url}, store in #{path}"
    begin
      file_name = File.basename(URI.parse(image_url).path)
      prefix = prefix.downcase.gsub(" ", "_").gsub("-","_").gsub("%", "_").gsub(":", "_")
      prefix = prefix.gsub("&", "_").gsub("#", "_").gsub(";", "_")
      file_name = file_name.downcase.gsub(" ", "_").gsub("-","_").gsub("%", "_").gsub(":", "_")
      file_name = file_name.gsub("&", "_").gsub("#", "_").gsub(";", "_")
      new_file_name = "#{prefix}_#{file_name}"

      image_obj = open(image_url)
      IO.copy_stream(image_obj, "#{path}#{new_file_name}")

      return new_file_name
      puts "Downloaded!"
      puts " "
    rescue Exception => e
      return "no_image.png"
    end

  end

  def self.download_image_demo
    puts "Downloading..."
    list_movie = Movie.take(10)
    list_movie.each_with_index do |movie, index|
      begin
        puts "Getting file #{movie[:cover]}"
        Post.download_image(movie[:cover], movie[:title])
      rescue Exception => e
        puts "Error! #{e.to_s}"
      end

    end
    puts "Download complete!"
  end

  def self.create_post_meta_demo
    # wp_json_body = HTTParty.get("#{API_POST_URL}/621/meta", basic_auth: BASIC_AUTH)
    # puts "api_url = #{API_POST_URL}"
    # puts "-----------------"
    # puts wp_json_body

    puts "Creating a post..."
    # result = HTTParty.post(
    #   "#{API_POST_URL}/631",
    #   :body => {
    #     :title => 'Test create post by Rails - Test updated',
    #     :content_raw => '<h1>Full content created by Rails - Test updated</h1>',
    #     :excerpt_raw => 'Text for excerpt of the post',
    #     :name => 'test create post by rails',
    #     :type => 'post',
    #     :status => 'publish'
    #   }.to_json,
    #   :headers => { 'Content-Type' => 'application/json' },
    #   :basic_auth => BASIC_AUTH
    # )
    # puts "result is #{result}"

    # youtube_url = "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/Sr9vUi3XND0\" frameborder=\"0\" allowfullscreen> </iframe>"
    # youtube_url_escape = CGI::escapeHTML(youtube_url)
    # result_meta = HTTParty.post(
    #   "#{API_POST_URL}/631/meta/5530",
    #   :body => {
    #     :key => "embed_pelicula",
    #     :value => youtube_url.gsub("\"","")
    #   }.to_json,
    #   :headers => { 'Content-Type' => 'application/json' },
    #   :basic_auth => BASIC_AUTH
    # )
    # puts "result is #{result_meta}"

    # youtube_url = "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/z4JxCx84QIM\" frameborder=\"0\" allowfullscreen></iframe>"
    # youtube_url_escape = CGI::escapeHTML(youtube_url)
    # result_meta = HTTParty.post(
    #   "#{API_POST_URL}/631/meta",
    #   :body => {
    #     :key => "embed_pelicula2",
    #     :value => youtube_url.gsub("\"","")
    #   }.to_json,
    #   :headers => { 'Content-Type' => 'application/json' },
    #   :basic_auth => BASIC_AUTH
    # )
    # puts "result is #{result_meta}"

    youtube_url = "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/z4JxCx84QIM\" frameborder=\"0\" allowfullscreen></iframe>"
    youtube_url_escape = CGI::escapeHTML(youtube_url)
    meta_body_1_1 = {key: "seasons_0_episode_5_url_tvshows", value: "doraemon-ep-336-doraemon-tv-series-2015"}
    meta_body_1_2 = {key: "seasons_0_episode_5_runtime_tvshows", value: "35 min"}
    meta_body_2 = {:key => "embed_pelicula3",:value => youtube_url.gsub("\"","")}
    # result_meta = HTTParty.post(
    #   "#{API_POST_URL}/645/meta",
    #   :body => meta_body_1_1.to_json,
    #   :headers => { 'Content-Type' => 'application/json' },
    #   :basic_auth => BASIC_AUTH
    # )
    # puts "result is #{result_meta}"

    # result_meta_2 = HTTParty.post(
    #   "#{API_POST_URL}/645/meta",
    #   :body => meta_body_1_2.to_json,
    #   :headers => { 'Content-Type' => 'application/json' },
    #   :basic_auth => BASIC_AUTH
    # )
    # puts "result is #{result_meta_2}"

    Post.update_post_tvshow_meta(645, 6594, "seasons_0_episode", "6")

    # puts "youtube_url_escape is #{youtube_url_escape}"
  end

  def self.create_post_demo
    puts "Creating a post..."
    result = HTTParty.post(
      "#{API_POST_URL}",
      :body => {
        :title => 'Test create tvshows post by Rails with image cover',
        :content_raw => '<h1>Full content created by Rails with image cover</h1>',
        :excerpt_raw => 'Text for excerpt of the tvshows post 2',
        :name => 'test create tvshows post by rails with category with image',
        :type => 'tvshows',
        :status => 'publish',
        :term => "cartoons",
        :tax => "tvshows_categories",
        :image_url => "http://www.cartoon2watch.com/wp-content/uploads/1.png"
        # "x-categories" => [51]
      }.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    meta_poster_url = Post.create_post_tvshow_meta(result["ID"], "poster_url", "http://www.cartoon2watch.com/wp-content/uploads/1.png")
    meta_cover_url = Post.create_post_tvshow_meta(result["ID"], "cover_url", "http://www.cartoon2watch.com/wp-content/uploads/1.png")
    puts "result is #{result}"

    return result

    # puts "Creating a meta for post..."
    #  	youtube_url = "<iframe src=\"http://auengine.com/embed.php?file=bmyVOeqE&w=680&h=390\" frameborder=\"0\" height=\"390\" scrolling=\"no\" width=\"680\"></iframe>"
    #    youtube_url_escape = CGI::escapeHTML(youtube_url)
    #    result_meta = HTTParty.post(
    #      "#{API_POST_URL}/631/meta",
    #      :body => {:key => "embed_pelicula4",:value => youtube_url.gsub("\"","")}.to_json,
    #      :headers => { 'Content-Type' => 'application/json' },
    #      :basic_auth => BASIC_AUTH
    #    )
    #    puts "result is #{result_meta}"

    #    puts "youtube_url_escape is #{youtube_url_escape}"
  end

  def self.count_ep_die
    # list_ep  = Post.where(:post_type => "episodios")
    list_ep = Post.joins(:post_metas).where("wp_postmeta.meta_key" => "tvplayer_0_embed_tvplayer").where(wp_postmeta: { meta_value: "" })
  end

end
