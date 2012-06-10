$(document).ready ->
  window.template_editor = ace.edit("editor")
  window.template_editor.getSession().setValue $("#code_holder").text()
  window.template_editor.setTheme("ace/theme/twilight")
  RubyMode = require("ace/mode/ruby").Mode
  window.template_editor.getSession().setMode(new RubyMode())
  window.template_editor.getSession().on "change", ->
    $('#code_holder').text window.template_editor.getSession().getValue()

  command =
    name: "gotoline"
    bindKey:
      win: "Ctrl-Return"
      mac: "Command-Return"
    exec: (editor, line)->
      processForm()

  window.template_editor.commands.addCommands([command])

  processForm = ->
    $("#form_upload_code").submit()

  $(".send-button").click ->
    processForm()

  $("#form_upload_code").submit ->
    request = $.ajax
      url: "/process"
      type: "POST"
      beforeSend: ->
        $("#loader").show()
      data:
        code: $("#code_holder").text()

    request.done (msg)->
      $("#loader").hide()
      $("#result_holder").html("#=> #{msg}")
    return false