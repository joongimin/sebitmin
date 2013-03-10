# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).delegate ".link_project", "click", () ->
  $project_stage = $(".project_stage")
  selected_project_id = $project_stage.find(".project_id").attr("value")
  $form = $(this).closest("form")
  if selected_project_id != $form.attr("action").substring(10)
    $(this).closest("form").submit()
  else
    UIUtil::remove_slow($project_stage.children())
    
  return false

$(document).delegate ".button_nav", "mouseenter", () ->
  $(this).stop().animate({opacity: 1}, 200)

$(document).delegate ".button_nav", "mouseleave", () ->
  $(this).stop().animate({opacity: 0.3}, 200)
  
$(document).delegate ".button_nav", "click", () ->
  $this = $(this)
  $project_presentation = $(this).closest(".project_presentation")
  if $this.hasClass("prev")
    is_prev = true
    $prev_photo = $this
    $next_photo = $project_presentation.find(".next")
  else
    is_prev = false
    $prev_photo = $project_presentation.find(".prev")
    $next_photo = $this

  $data_photos = $project_presentation.find(".data_photos")
  $img_container = $project_presentation.find(".image_container")
  photo_count = parseInt($data_photos.attr("photo_count"))
  index = parseInt($this.attr("index"))
  if 0 <= index && index < photo_count
    $prev_photo.attr("index", index - 1)
    $next_photo.attr("index", index + 1)
    $img = $("<img src=" + $data_photos.find("." + index).attr("photo_url") + "></img>")
    $img.hide()
    if is_prev
      $img_container.prepend($img)
      $img_container.css("left", "-800px")
    else
      $img_container.append($img)
      
    $project_presentation.addClass("in_transition")
    UIUtil::set_waiting($project_presentation)
    UIUtil::on_load $img, () ->
      UIUtil::clear_waiting($project_presentation)
      $img.show()
      
      on_finished_animation = () ->
        $img_container.empty()
        $img_container.append($img)
        $img_container.css("left", "0")
        $project_presentation.removeClass("in_transition")

      if is_prev
        $img_container.animate({left: 0}, 300, on_finished_animation)
      else
        $img_container.animate({left: -800}, 300, on_finished_animation)

    if index == 0
      $prev_photo.addClass("nav_end")
    else
      $prev_photo.removeClass("nav_end")

    if index == photo_count - 1
      $next_photo.addClass("nav_end")
    else
      $next_photo.removeClass("nav_end")
      
$(document).delegate ".scroll_to_top", "click", () ->
  $(".content").animate({scrollTop:0}, "fast");