// 記事本文の入力欄を Markdown エディタ（EasyMDE）にする
// EasyMDE 本体はレイアウトの <head> で、ログイン中だけ読み込んでいる
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { uploadUrl: String }

  connect() {
    if (typeof window.EasyMDE === "undefined") return

    this.editor = new window.EasyMDE({
      element: this.element,
      spellChecker: false,
      forceSync: true,
      uploadImage: this.hasUploadUrlValue,
      toolbar: [
        "bold", "italic", "strikethrough", "heading", "|",
        "quote", "unordered-list", "ordered-list", "|",
        "link", "image", ...(this.hasUploadUrlValue ? [ "upload-image" ] : []), "code", "table", "|",
        "preview", "side-by-side", "fullscreen", "|", "guide"
      ],
      imageUploadFunction: (file, onSuccess, onError) => this.upload(file, onSuccess, onError)
    })
  }

  disconnect() {
    if (this.editor) {
      this.editor.toTextArea()
      this.editor = null
    }
  }

  async upload(file, onSuccess, onError) {
    const body = new FormData()
    body.append("image", file)

    try {
      const response = await fetch(this.uploadUrlValue, {
        method: "POST",
        body,
        headers: { "X-CSRF-Token": this.csrfToken, "Accept": "application/json" },
        credentials: "same-origin"
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const { url } = await response.json()
      onSuccess(url)
    } catch (error) {
      onError(`画像のアップロードに失敗しました（${error.message}）`)
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content
  }
}
