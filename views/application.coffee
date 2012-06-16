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

  serverError = ->
    $(".loader").hide()
    showFailMessage("Ugh, there was an error connecting to our server. Please bare with us and try again soon.")

  processForm = (a)->
    $(document).find("form").submit()

  $(".send-button").click ->
    processForm(@)

  $("a.save-link").click ->
    request = $.ajax
      url: "/save"
      type: "POST"
      beforeSend: ->
        $(".loader").show()
      data:
        code: $("#code_holder").text()

    request.fail (result) ->
      serverError()

    request.done (result) =>
      $(".loader").hide()
      $("#error_message").slideUp("1000","easeOutExpo")
      $(@).text("Snippet saved!")
      $("a.saved-as").text("Direct Link")
      $("a.saved-as").attr("href","http://consola.herokuapp.com/snippet/#{result}")
    return false

  $("#form_tutorial_upload_code").submit ->
    request = $.ajax
      url: $(@).attr("action")#"/process"
      type: "POST"
      beforeSend: ->
        $(".loader").show()
      data:
        code: $("#code_holder").text()

    request.fail (result)->
      serverError()

    request.done (result)->
      result = JSON.parse(result)
      $("#error_message").slideUp("1000","easeOutExpo")
      $(".loader").hide()
      if error = result["error"]
        showFailMessage("Easy there, cowboy. There was a bug in your code: <br /><br /><strong>#{error}</strong>")

      results = result["execution"]
      html = "<ul>"
      for result in results
        if result["results"]["status"] == "passed"
          html += "<li><span class='success_test'>Everything is ok. <a href='#'>You can proceed to the next test</a></span></li>"
        else
          expected    = result["results"]["exception"]
          description = result["full_description"]
          html += "<li>Your code isn't right just yet. <br /><span class='failed_test'>When trying <strong>#{description}</strong> we found<br /><span>#{expected}</span></span></li>"

      html += "</ul>"
      $("#result_holder").html(html)
    return false


  $("#form_upload_code").submit ->
    request = $.ajax
      url: $(@).attr("action")#"/process"
      type: "POST"
      beforeSend: ->
        $(".loader").show()
      data:
        code: $("#code_holder").text()

    request.fail (result)->
      serverError()

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
    $("#result_holder").html("")

    div.html("<div id='content'>#{message}</div>")
    div.slideDown("6000", "easeOutBounce")