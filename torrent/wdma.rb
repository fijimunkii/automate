#!/usr/bin/env ruby
$stdout.sync = true

require 'rest-client'
require 'mechanize'
require 'logger'
require 'yaml'
require 'rss'

$config = YAML.load_file(File.join(__dir__, '../config.yml'))
$cookiejar = File.join(__dir__, '.cookies')
$tempfile = File.join(__dir__, '.temp')
$logger = Logger.new($stdout).tap { |log| log.progname = 'WDMA' }

$bot = Mechanize.new
$bot.pluggable_parser.default = Mechanize::Download
$bot.cookie_jar.load $cookiejar, :session => true, :format => :yaml

$history = []


module WDMA

  def self.watch
    print "Watching.."
    while true
      begin
        $config = YAML.load_file(File.join(__dir__, '../config.yml'))
        self.login if !self.logged_in?
        self.scrape
        sleep 1800
      rescue => e
        $logger.error e
        open('../.log', 'a') do |f|
          f << "uncaught #{e} exception while handling connection: #{e.message}\n"
          f << "Stack trace: #{e.backtrace.map {|l| "  #{l}\n"}.join}"
        end
      end
    end
  end

  def self.logged_in?
    $bot.get("https://#{$config['WDMA']['domain']}") do |page|
      !!!page.link_with(:text => /Login/)
    end
  end

  def self.login
    print "Logging in..\n"
    $bot.cookie_jar.clear!
    page = $bot.get "https://#{$config['WDMA']['domain']}"
    $bot.click(page.link_with(:text => /Login/))
      .form_with(:action => 'wp-login.php') do |f|
        f.log = $config['WDMA']['username']
        f.pwd = $config['WDMA']['password']
        f.checkbox.check
      end.submit
    $bot.cookie_jar.save_as $cookiejar, :session => true, :format => :yaml
  end

  def self.scrape
    self.login if !self.logged_in?
    $bot.get("https://#{$config['WDMA']['domain']}/rss.php").save! $tempfile

    RSS::Parser.parse(File.open($tempfile)).items.each do |item|
      print "."
      title = item.title.downcase.gsub(/^a-z0-9/i, '')
      $config['watch'].each do |watch|
        query = watch['name'].downcase.gsub(/^a-z0-9/i, '')

        if title.include?(query) && !$history.include?(title) && \
            ( watch['preference'].nil? ? true : title.include?(watch['preference']) ) 
          $history << title
          print "\n\nGrabbing #{item.title}\n\n"
          
          title = title[7..(title.index('thread')-2)]
          destination = $config['destination']
          destination += "#{watch['category']}/" if !watch['category'].nil?
          $bot.get(item.link).save! "#{destination}#{title}.torrent"
          
          # self.thank_post(item.thread_link)
          self.send_mail({'title' => title})
        end
      end
    end
  end

  def self.thank_post(thread_link)
#   self.login if !self.logged_in?
#   thread = $bot.get(thread_link)
#   $bot.click(thread.link_where(/Thank User/))
  end

  def self.send_mail(options)
    RestClient.post "https://api:#{$config['secret']['mailgun_key']}"\
      "@api.mailgun.net/v2/#{$config['secret']['mailgun_domain']}/messages",
      :from => "Alice <alice@gmail.com>",
      :to => $config['secret']['email'],
      :subject => "Downloading #{options['title']}",
      :text => ' from the usual spot.'
  end

  def self.upload(filename)
    self.login if !self.logged_in?
    $bot.get("https://#{$config['WDMA']['domain']}/u.php") do |page|
      print "Connected.\n"
      page.form_with(:method => /POST/) do |f|
        f.file_uploads.first.file_name = $config['PDF']['tempdir'] + filename
      end.submit 
      $bot.click(page.link_with(:text => /CLICK HERE/))
      .save! $config['destination'] + filename
    end
  end

end
