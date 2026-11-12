// スクロールに合わせてナビゲーションバーを固定・表示する
// （Start Bootstrap - Clean Blog v6.0.7 のスクリプトを Stimulus 用に書き直したもの / MIT License）
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollPos = 0
    this.headerHeight = this.element.clientHeight
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    const currentTop = window.scrollY
    const nav = this.element.classList

    if (currentTop < this.scrollPos) {
      // 上にスクロール中
      if (currentTop > 0 && nav.contains("is-fixed")) {
        nav.add("is-visible")
      } else {
        nav.remove("is-visible", "is-fixed")
      }
    } else {
      // 下にスクロール中
      nav.remove("is-visible")
      if (currentTop > this.headerHeight && !nav.contains("is-fixed")) {
        nav.add("is-fixed")
      }
    }
    this.scrollPos = currentTop
  }
}
