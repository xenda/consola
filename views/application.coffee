$(document).ready ->
  window.template_editor = ace.edit("editor")
  window.template_editor.getSession().setValue $("#code_holder").text()
  window.template_editor.setTheme("ace/theme/twilight")
  RubyMode = require("ace/mode/ruby").Mode
  window.template_editor.getSession().setMode(new RubyMode())
  window.template_editor.getSession().on "change", ->
    $('#code_holder').text window.template_editor.getSession().getValue()

  $(".send-button").click ->
    $(@).parent().submit()

  $("#form_upload_code").submit ->
    request = $.ajax
      url: "/process"
      type: "POST"
      data:
        code: $("#code_holder").text()

    request.done (msg)->
      $("#results_holder").append(msg)
    return false