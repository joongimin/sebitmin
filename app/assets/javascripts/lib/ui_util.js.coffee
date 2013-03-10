class @UIUtil
  transition_speed = 400
  
  autogrow: (event) ->
    target = event.target
    $target = $(target)
    if !target.shadow
      target.minHeight = $target.height()
      target.shadow = $('<div></div>').css({
        position:   'absolute',
        top:        -10000,
        left:       -10000,
        width:      $target.width() - parseInt($target.css('paddingLeft')) - parseInt($target.css('paddingRight')),
        fontSize:   $target.css('fontSize'),
        fontFamily: $target.css('fontFamily'),
        lineHeight: $target.css('lineHeight'),
        resize: 'none',
        wordWrap: 'break-word'
      }).appendTo(document.body)
    times = (string, number) ->
      r = ''
      for i in [0..number]
        r += string
      return r

    `val = target.value.replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/&/g, '&amp;')
                        .replace(/\n$/, '<br/>&nbsp;')
                        .replace(/\n/g, '<br/>')
                        .replace(/ {2,}/g, function(space) { return times('&nbsp;', space.length -1) + ' ' });`
    target.shadow.html val
    $target.css 'height', Math.max(target.shadow.height(), target.minHeight)
    return true

  isEnterKeydown: (event) ->
    return event.keyCode == 13 && !event.altKey && !event.ctrlKey && !event.shiftKey

  finishedEditingInput: ($input, enter_only, handler) ->
    if $input and !$input[0].isBound
      $input[0].isBound = true
      if !enter_only
        $input.blur () ->
          if !$input[0].isHandling
            $input[0].isHandling = true
            handler(false)
            $input[0].isHandling = false
      $input.bind "keydown keypress", (e) ->
        if !$input[0].isHandling && UIUtil::isEnterKeydown(e)
          $input[0].isHandling = true
          handler(true)
          $input[0].isHandling = false
          return false
        else
          return true

  getResourceId: ($element, resource_type) ->
    if $element
      id_string = $element.attr("id")
      if id_string && id_string.indexOf(resource_type + "_") != -1
        return id_string.replace(resource_type + "_", "")
    return "0"

  set_waiting: ($element) ->
    $element.append($("#shared_waiting_tmpl").tmpl())

  clear_waiting: ($element) ->
    $element.find(".waiting_indicator").remove()
    
  prepend_slow: ($target, $source) ->
    $source.hide().prependTo($target).animate({height: "toggle", opacity: "toggle"}, transition_speed)
    
  prepend_slow_opacity: ($target, $source) ->
    $source.hide().prependTo($target).animate({opacity: "toggle"}, transition_speed)
    
  remove_slow: ($target) ->
    $target.hide(transition_speed, () -> $target.remove())
    
  confirm: (title, message, callback_yes, callback_no) ->
    buttons = {}
    buttons[I18n.t("yes")] = {
      class: "icon iconButtonRedS red",
      action: callback_yes
    }
    
    buttons[I18n.t("no")] = {
      class: "icon iconButtonRedS red",
      action: callback_no
    }

    $.confirm({
      title: title,
      message: message,
      buttons: buttons
      })
      
  show_slow: ($target) ->
    $target.show(transition_speed)

  hide_slow: ($target) ->
    $target.hide(transition_speed)
      
  show_slow_opacity: ($target) ->
    $target.show()
    $target.animate({opacity: 1}, transition_speed)
      
  hide_slow_opacity: ($target) ->
    $target.animate({opacity: 0}, transition_speed, () -> $target.hide())
    
  show_slow_vertical: ($target) ->
    $target.show()
    $target.css("height", "auto")
    natural_height = $target.height()
    $target.css("height", 0)
    $target.animate({height: natural_height}, transition_speed)
    
  hide_slow_vertical: ($target) ->
    $target.animate({height: 0}, transition_speed, () -> $target.hide())
    
  remove_slow_vertical: ($target) ->
    $target.animate({height: 0, opacity: 0}, transition_speed, () -> $(this).remove())
    
  on_load: ($target, callback) ->
    if $target[0].complete
      callback()
    else
      $target.load () ->
        callback()