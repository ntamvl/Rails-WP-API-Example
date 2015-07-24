require 'nokogiri'
require 'phantomjs'
require 'cgi'

class KissAnime
  ANIME_HOST = "http://kissanime.com"
  PHANTOM_FILE = "kissanime_crawler.js"

  # crawl_url = http://kissanime.com/AnimeList?page=1
  def self.crawl_list_anime(crawl_url = "")
    puts 'Crawling list anime...'
    anime_links = []
    if crawl_url.present?
      html_content = Phantomjs.run(PHANTOM_FILE, crawl_url)
      page = Nokogiri::HTML(html_content)

      anime_title = page.css('title').first.text.split("-").first.gsub!(/[\n]+/, " ").strip
      puts "Title is #{anime_title}"

      rows = page.css('div.barContent div table.listing')
      rows.css('a').each_with_index do |row, index|
        anime_link = "#{ANIME_HOST}#{row['href']}"
        anime_links << anime_link
        puts "#{index} - #{anime_link}"
      end
    end

    puts 'Crawling completed!'
  end

  # anime_url = 'http://kissanime.com/Anime/hack-Roots-Dub'
  def self.crawl_list_episode(anime_url = "")
    puts 'Crawling list episode...'
    html_content = Phantomjs.run('kissanime_crawler.js', anime_url)
    result = {}
    episode_links = []
    page = Nokogiri::HTML(html_content)

    cover_image_crawl = page.css('div.rightBox div.barContent div img')
    puts "Cover------------------------- is #{cover_image_crawl}"
    if cover_image_crawl.present?
      result[:cover_image] = cover_image_crawl.first["src"]
    end

    anime_title = page.css('title').first.text.split("-").first.gsub!(/[\n]+/, " ").strip
    anime_name_src = page.css('div.bigBarContainer div.barContent div a.bigChar')
    if anime_name_src.present?
      puts "Name------------------"
      puts "#{anime_name_src.first['href']}"
      puts "Title is #{anime_title}"
      result[:anime_url] = "#{ANIME_HOST}#{anime_name_src.first['href']}"
      result[:anime_name] = anime_name_src.first.text
    end

    table_list = page.css('div.barContent.episodeList div table.listing')
    table_list.css('tr').each_with_index do |row, index|
      col_links = row.css('a')
      if col_links.present?
        link = col_links.first
        puts "#{index} #{link.text.gsub!(/[\n]+/, " ").strip} - #{link['href']}"
        episode_links << {name: link.text.gsub!(/[\n]+/, " ").strip, link: link['href']}
      end
    end
    result[:episode_links] = episode_links

    pp result
  end

  # episode_link = 'http://kissanime.com/Anime/Punchline/Episode-012?id=111445'
  def self.crawl_episode(episode_link)
    puts 'Crawling detail...'

    html_content = Phantomjs.run('kissanime_crawler.js', episode_link)
    direct_links = []
    result = {}

    page = Nokogiri::HTML(html_content)
    anime_title = page.css('title').first.text.split("-").first.gsub!(/[\n]+/, " ").strip
    puts "Anime episode: #{anime_title}"

    rows = page.css('div#divContentVideo div.fluid_width_video_wrapper')
    embed_code = rows.css('embed')


    if embed_code.present?
      flashvars = rows.css('embed')[0]["flashvars"]

      if flashvars.present?
        decode_flashvars = CGI.unescape(flashvars)

        stream_list = decode_flashvars.split("fmt_stream_map=").last.split("|")
        stream_list.each_with_index do |stream, index|
          if stream.length > 10
            # puts "-----------------"
            # puts "#{index} - #{stream.split(",").first}"
            link = stream.split(",").first
            direct_links << link
          end
        end

      end
    end
    # pp direct_links
    puts " "
    puts 'Crawling completed!'

    result[:name] = anime_title
    result[:direct_links] = direct_links
    puts "---------------------------"
    pp result
    return result
  end
end
