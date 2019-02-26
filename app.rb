require 'sinatra'
require "sinatra/activerecord"
require 'pry-byebug'
require 'line/bot'
require 'mechanize'
require 'pg'
require './whether.rb'

set :database, {adapter: "postgresql", database: "line_bot_development"}

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def fetch_rainy_percent_of_osaka
  agent = Mechanize.new
  page = agent.get('https://tenki.jp/forecast/6/30/6200/27100/')
  elements = page.search('.rain-probability td').inner_text
  string_array = elements.split('%')
  probability_array = string_array.map{ |s| s[/\d+/] }
  probability_array[1].to_i
end

def fetch_top_access_of_news
  news = {}
  agent = Mechanize.new
  page = agent.get('https://news.yahoo.co.jp/')
  elements = page.at('.yjnSub_list_wrap a')
  link = elements.get_attribute('href')
  title = elements.at('.yjnSub_list_head').inner_text
  source = elements.at('.yjnSub_list_source span').inner_text
  news[:link] = link
  news[:title] = title
  news[:source] = source
  news
end

get '/' do
  user = User.new
  user.name
  # rainy = fetch_rainy_percent_of_osaka
  # if rainy > 30
  #   push_content = {
  #     type: 'text',
  #     text: "今日の降水確率は#{rainy}%です。傘を持っていったほうがいいかもね。",
  #   }
  # else
  #   push_content = {
  #     type: 'text',
  #     text: "今日の降水確率は#{rainy}%です。傘はいらなそうだね。",
  #   }
  #   user_id = ENV["MY_USER_ID"]
  #   response = client.push_message(user_id, push_content)
  # end
end


post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  text_params = events[0]["message"]["text"]
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        if text_params =~ /天気/
          whether = Whether.new
          url = "http://weather.livedoor.com/forecast/webservice/json/v1?city=130010"
          hash_response = whether.fetch_whether_from(url)
          whether.set_todays_whether(hash_response)
          message = {
            type: 'text',
            text: "#{whether.datelabel}の天気は#{whether.telop}です。"
          }
          client.reply_message(event['replyToken'], message)
        elsif text_params =~ /ニュース/
          news = fetch_top_access_of_news
          message = {
            type: 'text',
            text: "今日のトップニュースは「#{news[:title]}」です。
            詳細は#{news[:link]}へどうぞ。（情報元：#{news[:source]}）"
          }
          client.reply_message(event['replyToken'], message)
        else
          message = {
            type: 'text',
            text: event.message['text'] + "…って、どういう意味ですか？"
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  }
  "OK"
end

class User < ActiveRecord::Base
  validates_presence_of :name
end

get '/users' do
  user = User.find(1)
  user.name
end

get '/users/create' do
  user = User.new(name: 'test1')
  user.save
end
