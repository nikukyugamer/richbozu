require 'feedjira'
require 'time'
require 'yaml'

class RichBozu
  YAML_FILENAME = 'config/rss_config.yml'

  def initialize(rss_config_title_name)
    rss_config = YAML.load_file(YAML_FILENAME)
    rss_uri = rss_config[rss_config_title_name]['rss_uri']

    @feed_data                    = Feedjira::Feed.fetch_and_parse(rss_uri).entries
    @latest_published_at_filepath = "latest_published_at/#{rss_config[rss_config_title_name]['latest_published_at_filename']}"
    @latest_all_text_filepath     = "latest_all_text/#{rss_config[rss_config_title_name]['latest_all_text_filename']}"
    @latest_published_at          = @feed_data[0].published # Time型
    @cybozu_board_name            = rss_config[rss_config_title_name]['cybozu_board_name']

    # TODO: 美しくない
    @text_header = <<~EOM
      #{rss_config[rss_config_title_name]['text_header']}
    EOM
  end

  def post_to_cybozu
    # const postMessage = (targetBoardName, targetReadFilename) => {
    # postMessage(process.argv[2], process.argv[3]);
    command = "node post_message.js #{@cybozu_board_name} #{@latest_all_text_filepath}"
    puts `#{command}`
  end

  def should_post?(all_text_contents)
    return true unless all_text_contents.empty?
    false
  end

  def utc_to_jst(utc_time_type)
    utc_time_type.localtime
  end

  def write_latest_published_at_to_file
    latest_published_at_jst_str = utc_to_jst(@latest_published_at).to_s

    File.open(@latest_published_at_filepath, 'w') do |f|
      f.print(latest_published_at_jst_str)
    end
  end

  def latest_published_at_from_file
    latest_published_at_from_file = ''

    if File.exists?(@latest_published_at_filepath)
      File.open(@latest_published_at_filepath, 'r') do |f|
        latest_published_at_from_file = f.read
      end
    else
      latest_published_at_from_file = '2018-01-01 12:00:00'
    end

    latest_published_at_from_file
  end

  def text_from_feed_item(feed_item)
    text_from_feed_item = ''

    if utc_to_jst(feed_item.published) > Time.parse(latest_published_at_from_file)

      # ここって汎用性あるのか否か
      text_from_feed_item = <<~EOM
        記事タイトル: #{feed_item.title}
        投稿日時: #{utc_to_jst(feed_item.published).to_s}
        記事URL: #{feed_item.url}
        記事概要: #{feed_item.summary.chomp}

      EOM
    end

    text_from_feed_item
  end

  def write_all_text_to_file
    if all_text_contents_from_all_feed_items.empty?
      File.delete(@latest_all_text_filepath) if File.exists?(@latest_all_text_filepath)
    else
      all_text = @text_header + all_text_contents_from_all_feed_items

      File.open(@latest_all_text_filepath, 'w') do |f|
        f.print(all_text)
      end
    end
  end

  def all_text_contents_from_all_feed_items
    all_text = ''

    @feed_data.each do |feed_item|
      content_text = text_from_feed_item(feed_item)
      all_text += content_text
    end

    all_text.chomp
  end

  def rss_contents
    write_all_text_to_file
    write_latest_published_at_to_file
  end

  def execute
    rss_contents
    post_to_cybozu
  end
end
