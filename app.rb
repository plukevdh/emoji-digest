$LOAD_PATH.unshift "./lib"
require 'roda'
require './roda/plugins/emoji'

require 'active_support/core_ext/date/calculations'

class App < Roda
  plugin :render,
         ext: "html.haml",
         engine: 'haml'
  plugin :emoji
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
        current = Date.today
        r.redirect "/digest/#{current.year}/#{current.cweek}"
      end

      r.on ":year/:week" do |year, week|
        date = Date.strptime "#{year},#{week}", "%Y,%W"
        view 'digest', locals: { emoji: digest_since(date).sort, date: date }
      end
    end

    r.assets
  end
end
