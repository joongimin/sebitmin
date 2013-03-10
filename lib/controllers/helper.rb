module Controllers
  module Helper
    def collect_result
      init_response(true)
    end
    
    def collect_result_new
      init_response_new(true)
    end

    def flush_result
      respond_to do |format|
        format.json { render_ajax_result }
      end
    end
    
    def flush_result_new
      respond_to do |format|
        format.json { render_ajax_result_new }
        format.html { render_html_result }
      end
    end
    
    def render_ajax_result
      if @ajax_result.delete(:encapsulate)
        render :status => 200, :json => "<textarea>#{@ajax_result.to_json}</textarea>", :content_type => "text/html"
      else
        render :status => 200, :json => @ajax_result
      end
    end
    
    def render_ajax_result_new
      self.formats = [:html]
      render_to_string("helper/ajax", :layout => false)
      $rendered_contents.each do |rendered_content|
        if $html_actions.include?(rendered_content[0])
          html_action = $html_actions[rendered_content[0]]
        else
          html_action = "replace"
        end
        @ajax_result[:updates].append({:target => "." + rendered_content[0].to_s, :html => rendered_content[1], :html_action => html_action})
      end
      if @ajax_result.delete(:encapsulate)
        render :status => 200, :json => "<textarea>#{@ajax_result.to_json}</textarea>", :content_type => "text/html"
      else
        render :status => 200, :json => @ajax_result
      end
    end
    
    def init_response(collect_result = false)
      if defined? @response_initialized
        return
      end

      @response_initialized = true
      @collect_result = collect_result

      @ajax_result = {}
      @ajax_result[:track_history] = true
      @ajax_result[:updates] = []
      
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end

    def init_response_new(collect_result = false)
      if defined? @response_initialized
        return
      end

      mime_type = Mime::Type.lookup(request.format.to_s)
      @request_type = mime_type.nil? ? nil : mime_type.symbol
      @response_initialized = true
      @collect_result = collect_result
      @render_templates = []
      @render_partials = []
      $html_actions = {}

      if @request_type != :html
        @ajax_result = {}
        @ajax_result[:track_history] = true
        @ajax_result[:updates] = []
      end

      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
    
    def get_path(args)
      if args.include?(:path)
        if args[:path] != ""
          args[:path]
        else
          nil
        end
      else
        "#{params[:controller]}/#{params[:action]}"
      end
    end
    
    def get_templates(args)
      path = get_path(args)
      if path.nil?
        templates = []
      else
        templates = [path]
      end
      
      # additional_templates = args.delete(:render_templates)
      # if !additional_templates.nil?
      #   templates += additional_templates
      # end
      
      templates
    end
    
    def render_html_result
      render "home/index"
    end
    
    def respond_to_ajax_new(args = {})
      init_response_new

      render_partials = args.delete(:render_partials)
      if !render_partials.nil?
        @render_partials += render_partials
      end

      if @request_type == :html && args.delete(:allow_html)
        @render_templates += get_templates(args)
      else
        format_ajax_new(args)
      end
      
      if !@collect_result
        flush_result_new
      end
    end

    def respond_to_ajax(args = {})
      init_response

      if @collect_result
        format_ajax(args)
      else
        respond_to do |format|
          format.json { format_ajax(args) }
        end
      end
    end

    def notice_to_ajax(notice_message)
      respond_to_ajax(:target => ".notice_area", :html => notice_message, :html_action => "notice", :track_history => false)
    end

    def add_options_to_ajax(additional = {})
      if @ajax_result[:additional].nil?
        @ajax_result[:additional] = additional
      else
        @ajax_result[:additional].merge(additional)
      end
    end
    
    def format_ajax_new(options = {})
      init_response_new
      self.formats = [:html]
      
      if options.include?(:track_history)
        @ajax_result[:track_history] = options[:track_history]
      else
        @ajax_result[:track_history] = true
      end

      if @ajax_result[:track_history]
        if options.include?(:history_path)
          @ajax_result[:path] = options[:history_path]
        else
          @ajax_result[:path] = request.path
        end
      end

      if options.include?(:title)
        @ajax_result[:title] = options[:title]
      end

      @render_templates += get_templates(options)
    end

    def format_ajax(options = {})
      init_response
      self.formats = [:html]

      if options.include?(:html)
        html = options[:html]
      else
        if options.include?(:path)
          path = options[:path]
        else
          path = "#{params[:controller]}/#{params[:action]}"
        end

        html = render_to_string(path, :layout => false)
      end

      if options.include?(:track_history)
        @ajax_result[:track_history] = options[:track_history]
      else
        @ajax_result[:track_history] = true
      end

      if @ajax_result[:track_history]
        if options.include?(:history_path)
          @ajax_result[:path] = options[:history_path]
        else
          @ajax_result[:path] = request.path
        end
      end

      if options.include?(:title)
        @ajax_result[:title] = options[:title]
      end
      
      if options.include?(:encapsulate)
        @ajax_result[:encapsulate] = options[:encapsulate]
      end

      if options.include?(:target)
        target = options[:target]
      else
        target = ".content_main"
      end
      
      if options.include?(:html_action)
        html_action = options[:html_action]
      else
        html_action = "replace"
      end
      
      @ajax_result[:updates].append({:target => target, :html => html, :html_action => html_action})

      if !@collect_result
        render_ajax_result
      end
    end

    def log_in(user)
      if allow_login(user)
        sign_in(:user, user)
      else
        return false
      end
    end
    
    def update_attribute(resource, name, value)
      if resource.update_attribute(name, value)
        sign_in resource, :bypass => true
      end
    end
    
    def respond_ok
      respond_to do |format|
        format.json { head :ok }
      end
    end
    
    def respond_with_error(error_message, args = {})
      logger.debug "respond_with_error #{error_message}"
      target = args.delete(:target) || ".error_message"
      respond_to_ajax(:target => target, :html => error_message, :html_action => "error", :track_history => false)
    end
    
    def escape_sql(query)
      query.gsub("%", "\%").gsub("_", "\_")
    end
    
    def locale_to_country_code(locale)
      case locale
      when :en
        "US"
      when :ko
        "KR"
      end
    end
  end
end
