$(document).ready ->
  window.template_editor = ace.edit("editor")
  window.template_editor.getSession().setValue $("#code_holder").text()
  window.template_editor.setTheme("ace/theme/twilight")
  RubyMode = require("ace/mode/ruby").Mode
  window.template_editor.getSession().setMode(new RubyMode())
  window.template_editor.getSession().on "change", ->
    $('#code_holder').text window.template_editor.getSession().getValue()
  $("#error_message").slideUp()
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
        $(".loader").show()
      data:
        code: $("#code_holder").text()

    request.fail (result)->
      $(".loader").hide()
      showFailMessage("Ugh, there was an error connecting to our server. Please bare with us and try again soon.")

    request.done (result)->
      result = JSON.parse(result)
      $("#error_message").slideUp("1000","easeOutExpo")
      $(".loader").hide()
      if error = result["error"]
        showFailMessage("Easy there, cowboy. There was a bug in your code: <br /><br /><strong>#{error}</strong>")

      eval_value = result["value"]
      eval_return = result["return"]
      eval_return = "nil" if eval_return  ==  ""

      $("#result_holder").html("#{eval_value}<br />#=> #{eval_return}")
    return false

  showFailMessage = (message)->
    div = $("#error_message")
    div.html("<div id='content'>#{message}</div>")
    div.slideDown("6000", "easeOutBounce")