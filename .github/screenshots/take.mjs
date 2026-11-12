// アプリを実際にブラウザで操作して、各画面のスクリーンショットを撮る
import { chromium } from "playwright"
import fs from "node:fs"

const BASE = "http://localhost:3000"
const OUT = "screenshots"
const PASSWORD = process.env.ADMIN_PASSWORD
fs.mkdirSync(OUT, { recursive: true })

const problems = []
const browser = await chromium.launch()

function watch(page, label) {
  page.on("console", (msg) => {
    if (msg.type() === "error") problems.push(`[${label}] console: ${msg.text()}`)
    else console.log(`  [${label}] console.${msg.type()}: ${msg.text()}`)
  })
  page.on("pageerror", (err) => problems.push(`[${label}] pageerror: ${err.message}`))
  page.on("requestfailed", (req) => problems.push(`[${label}] requestfailed: ${req.url()} ${req.failure()?.errorText}`))
  page.on("response", (res) => { if (res.status() >= 400) problems.push(`[${label}] HTTP ${res.status()}: ${res.url()}`) })
}

async function shot(page, name, opts = {}) {
  await page.waitForLoadState("networkidle")
  await page.waitForTimeout(600) // ナビの色の切り替えアニメーション（0.2秒）が終わるのを待つ
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage: opts.fullPage ?? true, animations: "disabled" })
  console.log(`saved ${name}.png  (${page.url()})`)
}

// ---------- PC 幅・未ログイン ----------
{
  const page = await (await browser.newContext({ viewport: { width: 1280, height: 800 }, locale: "ja-JP" })).newPage()
  watch(page, "pc-guest")
  await page.goto(BASE + "/");                       await shot(page, "01_pc_index")
  if (await page.getByText("まだ書きかけの記事").count()) problems.push("[pc-guest] 未ログインなのに下書きが一覧に出ている")
  console.log(`nav on load: ${await page.evaluate(() => { const n = document.getElementById("mainNav"); const cs = getComputedStyle(n); return `${n.className} | bg=${cs.backgroundColor} | transition=${cs.transition} | scrollY=${scrollY}` })}`)
  await page.getByRole("link", { name: "Rails 8 にアップデートした" }).first().click()
  await shot(page, "02_pc_post_code")
  await page.goto(BASE + "/");
  await page.getByRole("link", { name: "海辺で猫と過ごした週末" }).first().click()
  await shot(page, "03_pc_post_markdown")
  await page.goto(BASE + "/categories");             await shot(page, "04_pc_categories")
  await page.getByRole("link", { name: "猫" }).first().click()
  await shot(page, "05_pc_tag_posts")
  await page.goto(BASE + "/posts/new");              await shot(page, "06_pc_new_as_guest_redirects_to_login")

  // スクロールでナビが隠れる・戻る動き
  await page.goto(BASE + "/posts/" + (await firstPostId(page)))
  await page.mouse.wheel(0, 1200); await page.waitForTimeout(500)
  await page.mouse.wheel(0, -300); await page.waitForTimeout(500)
  await shot(page, "07_pc_navbar_after_scroll_up", { fullPage: false })
  const navClass = await page.getAttribute("#mainNav", "class")
  console.log(`navbar class after scroll: ${navClass}`)
}

// ---------- PC 幅・管理者 ----------
{
  const page = await (await browser.newContext({ viewport: { width: 1280, height: 900 }, locale: "ja-JP" })).newPage()
  watch(page, "pc-admin")

  await page.goto(BASE + "/login")
  await page.fill("input[name=password]", "wrong-password")
  await page.click("input[type=submit]")
  await shot(page, "08_pc_login_failed")

  await page.fill("input[name=password]", PASSWORD)
  await page.click("input[type=submit]")
  await page.waitForURL(BASE + "/").catch(() => problems.push(`[pc-admin] ログイン後にトップへ移動しない (${page.url()})`))
  await shot(page, "09_pc_after_login")

  await page.goto(BASE + "/")
  await shot(page, "09b_pc_index_as_admin_with_draft")
  await page.getByRole("link", { name: "New Post" }).click()
  await page.waitForSelector(".EasyMDEContainer", { timeout: 10000 }).catch(() => problems.push("[pc-admin] EasyMDE が表示されない"))
  await shot(page, "10_pc_new_post_editor")

  await page.fill("#post_title", "スクリーンショットからの投稿")
  await page.fill("#post_tag_names", "テスト、猫")
  await page.click(".CodeMirror")
  await page.keyboard.type("## 見出し\n\nエディタから入力した **本文** です。\n\n")

  // 画像アップロード（ツールバーの「画像をアップロード」ボタンを押してファイルを選ぶ）
  const uploaded = page.waitForResponse((res) => res.url().includes("/articles/attach"), { timeout: 15000 })
    .then(async (res) => console.log(`attach response: ${res.status()} ${await res.text()}`))
    .catch(() => problems.push("[pc-admin] 画像アップロードのリクエストが送られていない"))
  const [ chooser ] = await Promise.all([
    page.waitForEvent("filechooser"),
    page.click(".editor-toolbar button.upload-image")
  ])
  await chooser.setFiles("spec/fixtures/files/screenshot-sample.png")
  await uploaded
  await page.waitForTimeout(1000)
  console.log(`editor text: ${JSON.stringify(await page.evaluate(() => document.querySelector(".CodeMirror").CodeMirror.getValue()))}`)
  await shot(page, "11_pc_editor_filled")

  await page.check("#post_publish")
  await page.click("input[type=submit][value='保存する']")
  await page.waitForURL(/\/posts\/\d+$/).catch(() => problems.push(`[pc-admin] 投稿後に記事ページへ移動しない (${page.url()})`))
  await page.waitForSelector(".post-body")
  await page.evaluate(() => window.scrollTo(0, 0))
  await shot(page, "12_pc_created_post")
  const imgs = await page.locator(".post-body img").count()
  console.log(`images in created post: ${imgs}`)

  await page.getByRole("link", { name: "編集する" }).click()
  await page.waitForSelector(".EasyMDEContainer", { timeout: 10000 }).catch(() => problems.push("[pc-admin] 編集画面で EasyMDE が表示されない"))
  await shot(page, "13_pc_edit")

  await page.goto(BASE + "/")
  await page.getByRole("link", { name: "Logout" }).click()
  await shot(page, "14_pc_after_logout")
}

// ---------- スマホ幅 ----------
{
  const ctx = await browser.newContext({
    viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true, locale: "ja-JP",
    userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
  })
  const page = await ctx.newPage()
  watch(page, "mobile")
  await page.goto(BASE + "/");                       await shot(page, "15_mobile_index")
  await page.click(".navbar-toggler")
  await shot(page, "15b_mobile_menu_open", { fullPage: false })
  await page.getByRole("link", { name: "Rails 8 にアップデートした" }).first().click()
  await shot(page, "16_mobile_post_code")
  await page.goto(BASE + "/categories");             await shot(page, "17_mobile_categories")
}

async function firstPostId(page) {
  await page.goto(BASE + "/")
  const href = await page.locator(".post-title a").first().getAttribute("href")
  return href.split("/").pop()
}

await browser.close()

fs.writeFileSync(`${OUT}/problems.txt`, problems.length ? problems.join("\n") + "\n" : "問題なし\n")
console.log("---- problems ----")
console.log(problems.length ? problems.join("\n") : "none")
