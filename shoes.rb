require "rubygems"
require "serialport"
require 'weather_man'
require "date"
require "time"

WeatherMan.partner_id = '1108475457'
WeatherMan.license_key = 'c2ceac28a53c1dba'
$red = 3
$blue = 4
$device_list = [1]
#A class of "helper" functions that
#allow the shoes app to do it's job
class Send
  def print1
    puts 1
  end
  #Creates all the necissary variables
  def initialize(port)
    #params for serial port
    @port_str = "/dev/ttyUSB0"  #may be different for you
    @baud_rate = 9600
    @data_bits = 8
    @stop_bits = 1
    @parity = SerialPort::NONE
    @next_check = Time.now + (60 * 60)
    puts Time.now
    puts @next_check
  end

 #pulls information from weather.com and decides what
 #to do based upon the current condition
  def weather(devicenum)
    # Search for a location
    # Returns an array of WeatherMan objects
    # or if you know the location id or just want to use a US Zip code
    ny = WeatherMan.new('12180')
    weather = ny.fetch(:day => 0)
    description = weather.forecast.today.day.description
    puts description
    case description
    when /sun/i
      action = 15
    when /cloud/i
      action = 75
    when /shower/i
      action = 60
    when /few.+showers/i
      action = 40
    when /storm/i
      action = 100
    else
      action = 50
    end
    puts action
    action = (action * 2.55)
    puts action
    send_packet(devicenum, $red, action)
    send_packet(devicenum, $blue, action)
    @next_check = Time.now + (60 * 60)
  end
#sees if it is time to check weather.com yet
  def time_check()
    $device_list.each do |x| weather(x); end if Time.now<=>@next_check >= 0
  end
  #sends a complete packet to the arduino
  def send_packet(dest, dev, val)
	serial_send(dest)
	serial_send(dev)
	serial_send(val)
  end
  #send a third of a packet over serial.  Will be removed once I can
  #conferm the send_packet fully working without it (and by removed I
  #mean commented out of course) 
  def serial_send (input)
    SerialPort.open(@port_str, @baud_rate, @data_bits, @stop_bits, @parity) {|sp|
      sp.putc input.to_i(16)
    }
    puts input
  end
end

#End of Send class, start of shoes app
Shoes.app :width => 600, :height => 300 do
	send = Send.new("/dev/ttyUSB0")
	send.print1
	flow :width => 1.0 do
		stack  :width => 1.0, :height => 75 do
			title "Free Space Hydroponics"
		end
    stack :width => 0.5, :height => 225 do
      para "\n\nSlave Reactor Number:\n",
        "Device to alter:\n",
        "Value:", :size => 14
    end
		stack :width => 0.5, :height => 425 do
      para "\n"
			@s = edit_line :width => 200
      @d = edit_line :width => 200
      @v = edit_line :width => 200
      button("Send to device") do
        send.send_packet(@s.text, @d.text, @v.text)
			end
      			
    end		
   
  end
end
