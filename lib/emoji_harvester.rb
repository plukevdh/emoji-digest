require 'slack'

class EmojiHarvester
  APIError = Class.new(StandardError)

  def initialize(slack)
    @slack = slack
  end

  def harvest
    response = @slack.emoji_list
    raise APIError, 'Failed to fetch emoji' unless response['ok']

    dealias(response['emoji']).to_h
  end

  private

  def dealias(emotes)
    emotes.map do |name, url|
      if url.start_with? "alias:"
        emoji_alias = url.split(":")[1]
        url = emotes[emoji_alias]

        puts "fixing #{name} to #{emoji_alias} with #{url}"
      end

      [name, url]
    end
  end

end