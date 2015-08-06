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
  plugin :indifferent_params
  plugin :assets, css: ['emoji.css']

  Slack.configure do |config|
    config.token = ENV.fetch('SLACK_TOKEN')
  end

  def beginning_of_week_path
    beginning = Date.today.beginning_of_week
    "#{beginning.year}/#{beginning.month}/#{beginning.day}"
  end

  def parse_date(year, month, day)
    Date.strptime "#{year}/#{month}/#{day}", "%Y/%m/%d"
  end

  route do |r|
    r.root { r.redirect "/digest" }

    r.on "current" do
      view 'emoji', locals: { emoji: cached_emoji.sort }
    end

    r.on "random" do
      view 'random', locals: { random: random(params[:count]) }
    end

    r.on "digest" do
      r.get true do
        r.redirect "/digest/#{beginning_of_week_path}"
      end

      r.on ":year/:month/:day" do |year, month, day|
        date = parse_date(year, month, day)
        view 'digest', locals: { emoji: digest_since(date), date: date }
      end
    end

    r.on "json" do
      r.get true do
        r.redirect "/json/#{beginning_of_week_path}"
      end

      r.on ":year/:month/:day" do |year, month, day|
        date = parse_date(year, month, day)
        { emoji: digest_since(date), date: date }
      end

      r.on "random" do
        { emoji: random(params[:count]) }
      end
    end

    r.assets
  end
end
