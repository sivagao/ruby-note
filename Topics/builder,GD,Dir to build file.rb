require "builder"
builder = Builder::XmlMarkup.new
page = builder.html do |html|
  html.head { |head| head.title("Users") }
  html.body { |body| body.a("bob", "href" => "b1") }
end


require "GD"
image = GD::Image.new(100, 100)      # create an empty canvas, 100 pixels square
red = image.colorAllocate(255, 0, 0) # define the color red as RGB(255, 0, 0)
image.rectangle(25, 25, 75, 75, red) # draw a red square in a particular place
image.gif STDOUT                     # dump the GIF of this drawing to standard out


seconds_per_ip = 60 * 60 * 24 / 254.0
File.open("config.txt", "w") do |f|
  1.upto(254) do |d|
    seconds = (d - 1) * seconds_per_ip
    hrs = seconds / (60 * 60)
    mins = (seconds / 60) % 60
    secs = seconds % 60
    f.puts "1.2.3.#{d} " + sprintf("%.2i:%.2i:%.2i", hrs, mins, secs)
  end
end


Dir["*.[c|h]"].each do |path|
    lines = IO.readlines(path) # IO.readlines(path)
    
    line_number, first_year = nil, nil
    lines.each_with_index do |line, i|
        next unless line =~ /Copyright (\d+)/
        line_number, first_year = i, $1.to_i
        break
    end
    
    this_year = Time.now.year
    expected_notice = 
        if first_year and first_year < this_year
            "// Copyright #{first_year}-#{this_year} Andre Ben Hamou"
        else
            "// Copyright #{this_year} Andre Ben Hamou"
        end

    if line_number
        next if lines[line_number].chomp == expected_notice
        lines[line_number] = expected_notice
    else lines.unshift(expected_notice)
    end
    
    puts "Updating #{path.inspect}"
    File.open(path, "w") { |f| f.puts lines }
end