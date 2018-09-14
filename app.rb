require './rich_bozu'

richbozu = RichBozu.new(ARGV[0])
richbozu.rss_contents
richbozu.post_to_cybozu #=> RichBozu#rss_contents & RichBozu#post_to_cybozu = RichBozu#execute
