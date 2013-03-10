class @AjaxUtil
  constructor: () ->
    self = this
    $('#content').css('display', 'none')

    $.ajaxSettings.dataType = "json"

    $.history.init (hash) ->
      self.handleHistory(hash)

    @generatedId = 65535

  handleAjaxResponse: (e, data) ->
    if data.redirect
      window.location.href = data.redirect
      return

    if data.title
      document.title = "Nouvaux / " + data.title

    if data.updates
      for update in data.updates
        $target = $(update.target)
        if update.html_action == "replace"
          $target.html(update.html)
        else if update.html_action == "replace_slow"
          $html = $(update.html)
          $children = $target.children()
          if $children.length
            UIUtil::remove_slow($children)
          UIUtil::prepend_slow($target, $html)
        else if update.html_action == "prepend"
          $html = $(update.html)
          UIUtil::prepend_slow($target, $html)
        else if update.html_action == "prepend_opacity"
          $html = $(update.html)
          UIUtil::prepend_slow_opacity($target, $html)
        else if update.html_action == "add_class"
          $target.addClass(update.html)
        else if update.html_action == "remove"
          UIUtil::remove_slow($target)
        else if update.html_action == "notice"
          UIUtil::remove_slow($target.find(".notice"))
          UIUtil::prepend_slow($target, $("#shared_notice_tmpl").tmpl({ notice_message: update.html }))
        else if update.html_action == "popup"
          $target = $.confirm(html: update.html)
        else if update.html_action == "hide"
          UIUtil::hide_slow_opacity($target)
          
        # if $target
        #   window.initEventHandlers($target)
    @setContentLoaded()
    if @isBrowserUpdate
      @isBrowserUpdate = false
      return

    if data.track_history
      href = data.path
      if href
        @isHistoryUpdate = true
        $.history.load(href)

  handleHistory: (hash) ->
    if @isHistoryUpdate
      @isHistoryUpdate = false
      return

    if /^!/.test(hash)
      hash = hash.substring(1)

    if (!hash || hash == '/') && !@isContentLoaded
      @setContentLoaded()
      return

    self = this
    remoteElement = $("<a></a>").attr('href', hash)
    remoteElement.bind 'ajax:success', (e, data) ->
      self.isBrowserUpdate = true
      self.handleAjaxResponse(e, data)

    $.rails.handleRemote(remoteElement)
    return

  setContentLoaded: () ->
    if !@isContentLoaded
      $('#content').css('display', 'block')
      @isContentLoaded = true

  generateId: () ->
    return @generatedId++

  request: (path, method, callback_success) ->
    if method
      $form = $("<form action='" + path + "' method='" + method + "' style='display: none;'></form>")
      $form.bind "ajax:complete", (event) ->
        $form.unbind(event)
        $form.remove()
      $form.bind "ajax:success", (event, data) ->
        $form.unbind(event)
        if callback_success
          callback_success(event, data)
      $form.appendTo('body')
      $.rails.handleRemote($form)
      
  submit: ($form) ->
    if !window.FormData && !$form[0].encapsulated
      $form.append($("<input>").attr("type", "hidden").attr("name", "encapsulate").attr("value", "true"))
      $form.append($("<input>").attr("type", "hidden").attr("name", "format").attr("value", "json"))
      $form[0].encapsulated = true
    $form.ajaxSubmit(dataType: "json")

$(document).delegate $.rails.linkClickSelector + "," + $.rails.formSubmitSelector, "ajax:success", (e, data) ->
  window.ajaxUtil.handleAjaxResponse(e, data)
