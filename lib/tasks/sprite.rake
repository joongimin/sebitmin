require 'curb'

task :sprite => :environment do
  puts "Generating sprite"

  base_url = "http://spritegen.website-performance.org"
  sprites_zip_path = "sprites.zip"

  # zip sprite images
  system("zip #{sprites_zip_path} data/sprites/*")

  # Post request
  params = {
    "MAX_FILE_SIZE" => "524288",
    "ignore-duplicates" => "ignore",
    "width-resize" => "100",
    "height-resize" => "100",
    "aspect-ratio" => "on",
    "build-direction" => "vertical",
    "horizontal-offset" => "50",
    "vertical-offset" => "50",
    "wrap-columns" => "on",
    "background" => "",
    "use-transparency" => "on",
    "image-output" => "PNG",
    "image-num-colours" => "true-colour",
    "image-quality" => "75",
    "use-optipng" => "0",
    "selector-prefix" => "",
    "file-regex" => "",
    "class-prefix" => "icon_",
    "selector-suffix" => "",
    "add-width-height-to-css" => "on"
  }
  #response = Net::HTTP.post_form(URI.parse(base_url + "/"), params)
  post_data = params.map { |k, v| Curl::PostField.content(k, v) }
  post_data << Curl::PostField.file("path", "sprites.zip")
  c = Curl::Easy.new(base_url)
  c.multipart_form_post = true
  c.http_post(post_data)

  response = c.body_str

  # unlink zip
  File.unlink(sprites_zip_path)

  # Extract css
  start_index = response.index("readonly=\"readonly\"") + 20
  end_index = response.index("</textarea>", start_index) - 1
  css = response[start_index..end_index]
  
  pseudo_class_map = { "_over" => ":hover", "_click" => ":active", "_disable" => ":disabled", "_anchor" => "" }
  
  # Process css
  d = {}
  l = []
  lines = css.split("\n")
  for line in lines
    line_org = line
    index = line.index('{')
    name = line[0...index]
    css = line[index..-1]
    line = line[index+2..-1]
    index = line.index(';') + 1
    background_position = line[0...index]
    line = line[index+1..-1]
    index = line.index(";") + 1
    width = line[0...index]
    line = line[index+1..-1]
    index = line.index(';') + 1
    height = line[0...index]
    element = {}
    element[:name] = name
    element[:background_position] = background_position.gsub(";", " !important;")
    element[:width] = width
    element[:height] = height
    found = false
    pseudo_class_map.each do |k, v|
      if name.include?(k)
        found = true
        break
      end
    end
    if found
      d[name] = element
    else
      element[:camelcase_class] = name.camelcase
      element[:camelcase_name] = element[:camelcase_class][1..-1]
      l.append(element)
    end
  end

  s = "@import 'sprites_mixin';"
  s2 = ""
  for e in l
    s += "%{camelcase_class} {\n  @include %{camelcase_name};\n}\n\n" % e
    s2 += "@mixin %{camelcase_name} {\n  %{background_position}\n  %{width}\n  %{height}\n}\n\n" % e
    
    pseudo_class_map.each do |k, v|
      pseudo_name = e[:name] + k
      if d.key?(pseudo_name)
        o = d[pseudo_name]
        s += "a#{v} {\n  %{camelcase_class} {\n" % e
        s += "    %{background_position}\n" % o
        if o["width"] != e["width"]
          s += "    %{width}\n" % o
        end
        if o["height"] != e["height"]
          s += "    %{height}\n" % o
        end
        s += "  }\n}\n\n"
        s += "form {\n  %{camelcase_class}#{v} {\n" % e
        s += "    %{background_position}\n" % o
        if o["width"] != e["width"]
          s += "    %{width}\n" % o
        end
        if o["height"] != e["height"]
          s += "    %{height}\n" % o
        end
        s += "  }\n}\n\n"
        
        s2 += "@mixin %{camelcase_name}Over {\n" % e
        s2 += "  %{background_position}\n" % o
        if o["width"] != e["width"]
          s2 += "  %{width}\n" % o
        end
        if o["height"] != e["height"]
          s2 += "  %{height}\n" % o
        end
        s2 += "}\n\n"
        
        if k == "_disable"
          s2 += "@mixin %{camelcase_name}Disabled {\n" % e
          s2 += "  %{background_position}\n" % o
          if o["width"] != e["width"]
            s2 += "  %{width}\n" % o
          end
          if o["height"] != e["height"]
            s2 += "  %{height}\n" % o
          end
          s2 += "}\n\n"
          
          s += "a.disabled %{camelcase_class}, a.disabled %{camelcase_class}:hover, a.disabled %{camelcase_class}:active, %{camelcase_class}.disabled, %{camelcase_class}.disabled:hover, %{camelcase_class}.disabled:active {\n" % e
          s += "  @include %{camelcase_name}Disabled;\n" % e
          s += "}\n\n"
        end
      end
    end
  end

  # Save css
  css_path = "app/assets/stylesheets/base/sprites.css.scss"
  system("chmod +w #{css_path}")

  f = File.new(css_path, "w")
  f.write(s)
  f.close

  # Save mixin
  css_mixin_path = "app/assets/stylesheets/_sprites_mixin.scss"
  system("chmod +w #{css_mixin_path}")

  f = File.new(css_mixin_path, "w")
  f.write(s2)
  f.close

  # Extract download path
  start_index = response.index("<a class=\"download\"") + 26
  end_index = response.index("\"", start_index) - 1
  image_url = response[start_index..end_index].gsub("&amp;", "&")

  image_path = "app/assets/images/icons.png"
  system("chmod +w #{image_path}")

  # Download image
  system("wget -O #{image_path} \"#{base_url}#{image_url}\"")
  puts "Generated sprite successfully!"
end
