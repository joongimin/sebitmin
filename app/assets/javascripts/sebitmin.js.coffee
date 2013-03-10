$(document).ready () ->
  window.ajaxUtil = new AjaxUtil
  
$(document).delegate ".selectable_menu", "click", () ->
  $(".selectable_menu").removeClass("selected")
  $(this).addClass("selected")
  
$(document).delegate "input.autoSubmit", "change", (e) ->
  $this = $(this)
  AjaxUtil::submit($this.closest('form'))
  $this.val("")