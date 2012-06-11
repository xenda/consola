$(document).ready ->
  window.template_editor = ace.edit("editor")
  editor_session = window.template_editor.getSession()
  editor_session.setValue $("#code_holder").text()
  window.template_editor.setTheme("ace/theme/twilight")
  RubyMode = require("ace/mode/ruby").Mode
  editor_session.setMode(new RubyMode())
  editor_session.setTabSize(2);
  editor_session.setUseSoftTabs(true);
  editor_session.setUseWrapMode(true);
  window.template_editor.setShowPrintMargin(false);



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

  $("a.save-link").click ->
    request = $.ajax
      url: "/save"
      type: "POST"
      beforeSend: ->
        $(".loader").show()
      data:
        code: $("#code_holder").text()

    request.fail (result) ->
      $(".loader").hide()
      showFailMessage("I'm sorry... I'm so sorry. Something failed and we couldn't save it. Try again!")

    request.done (result) =>
      $(".loader").hide()
      $("#error_message").slideUp("1000","easeOutExpo")
      $(@).text("Snippet saved!")
      $("a.saved-as").text("Direct Link")
      $("a.saved-as").attr("href","http://consola.herokuapp.com/snippet/#{result}")
    return false

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