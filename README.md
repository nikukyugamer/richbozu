# Rich Bozu

## What's this?
- GET the latest RSS (**Rich** Site Summary) and POST to Cy**bozu**
    - Rich to Bozu, therfore `Rich Bozu`

# Installation
## Install gems and node packages

```bash
$ bundle install
$ yarn install
```

## Install `.env` file
- `.env` file's content is as below

```
CYBOZU_DIGEST_AUTH_USERNAME=YOUR_DIGEST_AUTH_USERNAME
CYBOZU_DIGEST_AUTH_PASSWORD=YOUR_DIGEST_AUTH_PASSWORD
CYBOZU_USERNAME=YOUR_CYBOZU_USERNAME
CYBOZU_PASSWORD=YOUR_CYBOZU_PASSWORD
```

- Use sample `.env` file if you need

```bash
$ cp .env.sample .env
```

# Configuration

## config/rss_config.yml
- Write RSS configuration to `config/rss_config.yml`

```yaml
bslog_com: # an item name is used as ARGV
  name: ビーズログ.com # not used in script so for human understanding 
  rss_uri: https://www.bs-log.com/feed/
  latest_published_at_filename: bslog_latest_published_at.txt
  latest_all_text_filename: bslog_latest_all_text.txt
  text_header: ビーズログ.com の最新記事
  cybozu_board_name: config_name_02 # IMPORTANT: this item name is acquired from 'config/cybozu_config.yml' 
```

## config/cybozu_config.yml
- Write Cybozu configuration to `config/cybozu_config.yml`

```yaml
config_name_01: # IMPORTANT: this item name is used in 'config/rss_config.yml' (at 'cybozu_board_name')
  name: 'イーブイ' # not used in script so for human understanding 
  post_page: 'https://onlinedemo.cybozu.info/scripts/office10/ag.cgi?page=MyFolderMessageView&mid=4&mdbid=4' # Refer to following screenshot
  textbox_id: '#Data-b92' # Inspect by DevTools (Refer to following screenshot)
```

# Configuration Example (with screenshot)
- Copy below url and paste to `post_page` in `config/cybozu_config.yml`

![post_page](post_page.png 'post_page の抽出')

- Check the `id`'s value of Textbox (Textarea) and paste it to `textbox_id` in `config/cybozu_config.yml`
    - in case of below example, `Data-b92` is that value
    - https://onlinedemo.cybozu.info/scripts/office10/ag.cgi?page=MyFolderMessageView&mid=4&mdbid=4

![textbox_sample](textbox_sample.png 'post_page の抽出')

![textbox_id](textbox_id.png 'textbox_id の抽出')

# Run
- the template of `app.rb` is `app.sample.rb`

```bash
$ bundle exec ruby app.rb bslog_com # ARGV is the item name in 'config/rss_config.yml'
```

# Deploy
- Now manually...

```bash
$ cd /path/to/richbozu && git pull
```

# Set cron
- [`Whenever`](https://github.com/javan/whenever) is recommended

# Note
- If you needn't digest auth logic, remove it
- Many access in short interval may cause something bad...
    - devide execution files

# TODO
- Store articles information to RDB?
- Write test codes
