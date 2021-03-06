require 'sinatra'
require "sinatra/activerecord"
require "sinatra/reloader" if development?
require 'pry-byebug'
require 'line/bot'
require 'pg'
require './model/application_model'
require 'natto'

# set :database, {adapter: "postgresql", }

configure :development do
  set :database, {adapter: 'postgresql', database: "line_bot_development"}
end

configure :production do
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

# ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] )

post '/callback' do

  #本番環境ではコメントアウトする

  load "./model/replier.rb"
  load "./model/whether.rb"
  load "./model/news.rb"
  load "./model/battle_choice.rb"
  load "./model/brain.rb"
  load "./model/fight.rb"

  replier = Replier.new(request)

  unless replier.validate_of(replier.request)
    error 400 do 'Bad Request' end
  end

  brain = Brain.new(user: replier.user,
                    events: replier.events)
  brain.set_user_status
  message = brain.delegate_to_class_to_create_message
  replier.reply(message)
  # replier.reply_message
  'OK'
end

get '/whether' do

  load "./model/brain.rb"
  text_params = "こんにちは、明日の大阪はどんな日になるだろう"
  arr = []
  natto = Natto::MeCab.new
  natto.parse(text_params) do |n|
    arr << {n.surface => n.feature.split(",")}
  end
  arr.inspect

end
