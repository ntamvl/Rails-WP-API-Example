require 'httparty'
require 'json'

class Post < ActiveRecord::Base
  API_URL = 'http://www.cartoon2watch.com/wp-json'
  API_POST_URL = 'http://www.cartoon2watch.com/wp-json/posts'
  BASIC_AUTH = {:username => "tamnguyen", :password => "nguyen"}
  POST_TYPE = {tvshows: "tvshows", episode: "episodios"}

  def self.create_multi_posts
  	list_movie = Movie.all
  	list_movie.each do |movie|
  		# str.strip.downcase.gsub(/\s+/," ").gsub(" ","-")
  		returned_movie = Post.create_post_tvshow(movie)
  	end
  end

  def self.create_post_tvshow(m_movie)
    puts "Creating a post..."
    post_body = {
      :title => m_movie[:title],
      :content_raw => m_movie[:summary],
      :excerpt_raw => m_movie[:other_title],
      :name => m_movie[:title],
      :type => 'tvshows',
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
      :body => {:key => "#{meta_key}",:value => meta_value.gsub("\"","")}.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    puts "result for post #{post_id} is #{result_meta}"
  end

  def self.get_post_demo
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
    result_meta = HTTParty.post(
      "#{API_POST_URL}/631/meta",
      :body => {:key => "embed_pelicula3",:value => youtube_url.gsub("\"","")}.to_json,
      :headers => { 'Content-Type' => 'application/json' },
      :basic_auth => BASIC_AUTH
    )
    puts "result is #{result_meta}"

    puts "youtube_url_escape is #{youtube_url_escape}"
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

end
