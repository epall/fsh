require "rubygems"
require "serialport"
require 'weather_man'
require "date"
require "time"
require "net/toc"
require 'net/http'
require 'uri'

WeatherMan.partner_id = '1108475457'
WeatherMan.license_key = 'c2ceac28a53c1dba'
$red = 3
$blue = 4
$device_list = [1]

class Twitter

  TW_USER = 'freespacehydro'
  TW_PASS = 'tennis'
  TW_URL = 'http://twitter.com/statuses/update.xml'
  MAX_LEN = 140
  def initialize

  end
  def update(msg)
    message = msg
    if message.length > MAX_LEN
      puts "Sorry, your message was #{message.length} characters long; the limit is #{MAX_LEN}."
    elsif message.empty?
      puts "No message text selected!"
    end
    begin
      url = URI.parse(TW_URL)
      req = Net::HTTP::Post.new(url.path)
      req.basic_auth TW_USER, TW_PASS
      req.set_form_data({'status' => message})
      begin
        res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          if res.body.empty?
            puts "Twitter is not responding properly"
          else
            puts 'Twitter update succeeded'
          end
        else
          puts 'Twitter update failed for an unknown reason'
          # res.error!
        end
      rescue
        puts $!
        #puts "Twitter update failed - check username/password"
      end
    rescue SocketError
      puts "Twitter is currently unavailable"
    end
  end
end



class Send
  def print1
    puts 1
  end
  
  def initialize(port)
    #params for serial port
    @port_str = "/dev/ttyUSB0"  #may be different for you
    @baud_rate = 9600
    @data_bits = 8
    @stop_bits = 1
    @parity = SerialPort::NONE
    @status = "Nothing Yet"
    @last_action = 0
    @twit = Twitter.new()
    @t1 = Thread.new{
      while true do
        puts "here"
        weather()
        puts "there"
        sleep(3600)
      end
    }
    @t1.run
    @t2= Thread.new {
      Net::TOC.new("FreeSpaceHydro", "tennis") do |msg, buddy|
        buddy.send_im("#{@status}")
        begin
          if msg.match(/switch/)
            msg[/switch/] = ''
            a = msg[/\d/]
            msg[a] = ''
            b = msg[/\w+/]
            msg[b] = ''
            c = msg[/\d+/]
            msg[c] = ''
            send_packet(a, $red, c * 2.55) if b.match(/red/i)
            send_packet(a, $blue, c * 2.55) if b.match(/blue/i)
          end
        rescue
  
        end
      end    
    }
    @t2.run
  end

  def toggle_weather() 
    weather()
  end

  def toggle() 
    if @last_action == 0
      send_packet(1, $red, 255)
      send_packet(1, $blue, 255)
    else
      send_packet(1, $red, 0)
      send_packet(1, $blue, 0)
    end
  end

 
  def weather()
    # Search for a location
    # Returns an array of WeatherMan objects
    # or if you know the location id or just want to use a US Zip code
    begin
      ny = WeatherMan.new('12180')
      weather = ny.fetch(:day => 0)
      description = weather.forecast.today.day.description
      puts description
      case description
      when /sun/i
        action = 15
        @status = "It's very bright out!  Turning off my light!"
      when /cloud/i
        action = 75
        @status = "It's dark out - I need more light!"
      when /shower/i
        action = 60
        @status = "Yay water!  I enjoy a good shower."
      when /few.+showers/i
        action = 40
        @status = "Some rain is better than none!"
      when /storm/i
        action = 100
        @status = "GAH! Storms!  LIGHTS ON!"
      else
        action = 50
        @status = "I'm indecicive right now..."
      end
    rescue
      action = 50
      @status = "Ack! Problems!"
    ensure
      @twit.update(@status)
      puts action
      action = (action * 2.55)
      puts action
      serial_send(1)
      serial_send($red)
      serial_send(action)
      serial_send(1)
      serial_send($blue)
      serial_send(action)
      puts "done"
    end
  end

  def serial_send (input)
    SerialPort.open(@port_str, @baud_rate, @data_bits, @stop_bits, @parity) {|sp|
    sp.putc input.to_i(10)
    puts "sending: #{input}"
    @last_action = input
    }
  end
  
  def send_packet(x, y, z)
    serial_send(x)
    serial_send(y)
    serial_send(z)
  end
end

Shoes.app :width => 600, :height => 300 do
  send = Send.new("/dev/ttyUSB0")
  send.print1
  flow :width => 1.0 do
    background green
    stack  :width => 1.0, :height => 75 do
      background green
      title "Free Space Hydroponics"
    end
    stack :width => 0.5, :height => 225 do
      background green
      para "\n\nSlave Reactor Number:\n",
        "Device to alter:\n",
        "Value:", :size => 14
    end
    stack :width => 0.5, :height => 150 do
      background green
      para "\n"
      @s = edit_line :width => 200
      @d = edit_line :width => 200
      @v = edit_line :width => 200
    end
    stack :width => 0.51, :height => 75 do
      background green
    end
    stack :width => 0.1, :height => 75 do
      background green      
      button("Send") do
        device = 3 if @d.text.match(/red/i)
        device = 4 if @d.text.match(/blue/i)
        send.serial_send(@s.text)
        send.serial_send(device) if device != nil
        send.serial_send(@d.text) if device == nil
        send.serial_send(@v.text)
        #alert("Sent #{@s.text}, #{@d.text}, #{@v.text}")
      end
    end
    stack :width => 0.1, :height  => 75 do
      background green
      button("Auto") do
        send.toggle_weather()
      end
    end
    stack :width => 0.15, :height => 75 do
      background green
      button("Toggle") do
        send.toggle()
      end
    
    end

  end
end
