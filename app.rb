$LOAD_PATH.unshift "./lib"
require 'roda'
require './roda/plugins/emoji'

require 'active_support/core_ext/date/calculations'

class App < Roda
  plugin :render,
         ext: "html.haml",
         engine: 'haml'
  plugin :emoji
  plugin :json
  plugin :assets, css: ['emoji.css']

  Slack.configure do |config|
    config.token = ENV.fetch('SLACK_TOKEN')
  end

  route do |r|
    r.root { r.redirect "/digest" }

    r.on "current" do
      view 'emoji', locals: { emoji: cached_emoji.sort }
    end

    r.on "digest" do
      r.get true do
        beginning = Date.today.beginning_of_week
        r.redirect "/digest/#{beginning.year}/#{beginning.month}/#{beginning.day}"
      end

      r.on ":year/:month/:day" do |year, month, day|
        date = Date.strptime "#{year}/#{month}/#{day}", "%Y/%m/%d"
        view 'digest', locals: { emoji: digest_since(date), date: date }
      end
    end

    r.on "json" do

      r.get true do
        beginning = Date.today.beginning_of_week
        r.redirect "/json/#{beginning.year}/#{beginning.month}/#{beginning.day}"
      end

      r.on ":year/:month/:day" do |year, month, day|
        date = Date.strptime "#{year}/#{month}/#{day}", "%Y/%m/%d"
        { emoji: digest_since(date), date: date }
      end
    end

    r.assets
  end
end
