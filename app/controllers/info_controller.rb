class InfoController < ApplicationController
  include Controllers::Helper
  
  def about_me
    respond_to_ajax_new(:allow_html => true)
  end
end
