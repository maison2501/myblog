// app/javascript/controllers/ にある *_controller.js を自動で登録する
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)
