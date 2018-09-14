require('dotenv').config()

const yaml = require('js-yaml');
const fs = require('fs');
const puppeteer = require('puppeteer');
const ourCybozuHome = 'YOUR_CYBOZU_HOME'; // https://onlinedemo.cybozu.info/scripts/office10/ag.cgi
const cybozuConfig = yaml.safeLoad(fs.readFileSync('config/cybozu_config.yml', 'utf8'));

const postMessage = (targetBoardName, targetReadFilename) => {
  const readFilename = targetReadFilename;

  fs.readFile(readFilename, 'utf8', (err, text) => {
    (async () => {
      const browser = await puppeteer.launch({
        headless: true,
        args: [
          '--no-sandbox'
        ]
      });

      const targetPostpage  = cybozuConfig[targetBoardName]['post_page'];
      const textboxId       = cybozuConfig[targetBoardName]['textbox_id'];
      const USERNAME        = process.env.CYBOZU_USERNAME;
      const PASSWORD        = process.env.CYBOZU_PASSWORD;
      const targetToppage   = ourCybozuHome;
      let POST_MESSAGE      = '';

      const page = await browser.newPage();

      try {
        if (text == null) {
          throw new Error('readFile is null'); // 新しい記事がない場合はファイルを出力しないようにしているのでここにたどり着く
        } else {
          POST_MESSAGE = text;
        }
      } catch(e) {
        await browser.close();

        console.log('readFile Error!');
        throw new Error('readFile error occured so exit');
      }

      // Digest 認証
      await page.setExtraHTTPHeaders({
          Authorization: `Basic ${new Buffer(`${process.env.CYBOZU_DIGEST_AUTH_USERNAME}:${process.env.CYBOZU_DIGEST_AUTH_PASSWORD}`).toString('base64')}`
      });
      await page.goto(targetToppage, { waitUntil: 'networkidle0' });

      // login（digest 認証 がある場合）
      await page.type('input[name="username"]', USERNAME);
      await page.type('input[name="password"]', PASSWORD);
      await page.click('#login-form-outer > form > div.login-dialog-footer > div.login-dialog-footer-right > input');
      await page.waitFor(5000);

      // 掲示板（メッセージ）へ移動する
      await page.goto(targetPostpage, { waitUntil: 'networkidle0' });

      // テキストボックスにテキストを入力する（掲示板ごとに異なる id になる）
      await page.type(textboxId, POST_MESSAGE);

      // POST する
      await page.click('#followAddButton');
      await browser.close();
    })();
  })
}

postMessage(process.argv[2], process.argv[3]);
