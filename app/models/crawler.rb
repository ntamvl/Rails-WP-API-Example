require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'wombat'
require 'mechanize'
require 'capybara'
require 'phantomjs'
require 'cgi'

class Crawler
  include Capybara::DSL

  BASE_WIKIPEDIA_URL = "http://en.wikipedia.org"
  LIST_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_Nobel_laureates"

  def self.demo1
    page = Nokogiri::HTML(open(LIST_URL))
    rows = page.css('div.mw-content-ltr table.wikitable tr')

    rows[1..-2].each do |row|

      hrefs = row.css("td a").map{ |a|
        a['href'] if a['href'] =~ /^\/wiki\//
      }.compact.uniq

      hrefs.each do |href|
        remote_url = BASE_WIKIPEDIA_URL + href
        puts remote_url
      end # done: hrefs.each

    end # done: rows.each

  end

  def self.get_kissanime_list
    anime_url = "http://kissanime.com/AnimeList"
    page = Nokogiri::HTML(Page.get(anime_url))
    rows = page.css('div.barContent div table.listing')
    puts rows
  end

  def self.crawl_2
    # agent = Mechanize.new
    # page = agent.get('http://google.com/')
    # puts page
    Wombat.crawl do
      # error when crawl kissanime
      # base_url "http://kissanime.com/AnimeList"
      # path "/"
      # headline xpath: "//h1"
    end
    #   Wombat.crawl do
    #     base_url "https://www.github.com"
    #     path "/"

    #     headline xpath: "//h1"
    #     subheading css: "p.subheading"

    #     what_is({ css: ".one-half h3" }, :list)

    #     links do
    #       explore xpath: '//*[@class="wrapper"]/div[1]/div[1]/div[2]/ul/li[1]/a' do |e|
    #         # e.gsub(/Explore/, "Love")
    #       end

    #       features css: '.features'
    #       enterprise css: '.enterprise'
    #       blog css: '.blog'
    #     end
    #   end
  end

  def self.demo3
    # visit "http://ngauthier.com/"
    url = 'http://kissanime.com/AnimeList'
    head_response = HTTParty.get(url,
                                 follow_redirects: true,
                                 maintain_method_across_redirects: true
                                 )
  end

  def self.crawl_list_anime
    puts 'Crawling list anime...'
    anime_host = "http://kissanime.com"
    crawl_url = 'http://kissanime.com/AnimeList'
    html_content = Phantomjs.run('kissanime_crawler.js', crawl_url)
    anime_list = []

    page = Nokogiri::HTML(html_content)

    anime_title = page.css('title').first.text.split("-").first.gsub!(/[\n]+/, " ").strip
    puts "Title is #{anime_title}"

    rows = page.css('div.barContent div table.listing')
    rows.css('a').each_with_index do |row, index|
      anime_link = "#{anime_host}#{row['href']}"
      puts "#{index} - #{anime_link}"
    end

    puts 'Crawling completed!'
  end

  def self.crawl_list_ep
    puts 'Crawling list episode...'
    crawl_url = 'http://kissanime.com/Anime/hack-Roots-Dub'
    html_content = Phantomjs.run('kissanime_crawler.js', crawl_url)
    # puts html_content
    page = Nokogiri::HTML(html_content)
    table_list = page.css('div.barContent.episodeList div table.listing')
    table_list.css('tr').each_with_index do |row, index|
      col_links = row.css('a')
      if col_links.present?
        link = col_links.first
        puts "#{index} #{link.text.gsub!(/[\n]+/, " ").strip} - #{link['href']}"
      end
    end
  end

  def self.crawl_detail_ep
    puts 'Crawling detail...'
    crawl_url = 'http://kissanime.com/Anime/Punchline/Episode-012?id=111445'
    html_content = Phantomjs.run('kissanime_crawler.js', crawl_url)
    direct_links = []

    page = Nokogiri::HTML(html_content)
    anime_title = page.css('title').first.text.split("-").first.gsub!(/[\n]+/, " ").strip
    puts "Title is #{anime_title}"
    rows = page.css('div#divContentVideo div.fluid_width_video_wrapper')
    embed_code = rows.css('embed')
    # puts "Embed code"
    # puts embed_code

    if embed_code.present?
      flashvars = rows.css('embed')[0]["flashvars"]
      # puts "flashvars"
      # puts flashvars

      if flashvars.present?
        decode_flashvars = CGI.unescape(flashvars)

        # puts "unescape"
        # puts CGI.unescape(decode_flashvars)

        stream_list = decode_flashvars.split("fmt_stream_map=").last.split("|")
        stream_list.each_with_index do |stream, index|
          if stream.length > 10
            puts "-----------------"
            puts "#{index} - #{stream.split(",").first}"
          end
        end
        # puts rows

      end
    end
    puts " "
    puts 'Crawling completed!'
  end

end
