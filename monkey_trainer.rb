require 'pp'
require 'socket'


class MonkeyTrainer
  PACKET_LENGTH = 2048
  SERVER_IP_ADDRESS = '127.0.0.1'
  SERVER_PORT = 6789

  def connect
    udp_send('CONNECT')
    udp_send('TRAIN')
    udp_send('SPEED,FAST')
  end

  def disconnect
    udp_send('QUIT')
    udp_send('DISCONNECT')
  end

  def generate_training_data(hits_target = 1000)
    results = []
    # done = false
    # 5000.times do |i|
    hits = 0
    while hits < hits_target
      target_info = get_target_info
      angle = prng.rand(1.0) + 0.2
      force = 50.0 # prng.rand(50.0) + 50.0
      shot_response = send_shot_info(angle, force)
      if shot_response == 'HIT'
        hits += 1
        p "#{hits} / #{hits_target} --------------------"
        results << { input: target_info, output: [angle, force] }
      end
      send_reset
    end
    results
  end

  def get_target_info
    target_response = udp_send('TARGET').first
    response_pieces = target_response.split(',')
    [response_pieces[1].to_f, response_pieces[2].to_f]
  end

  def send_shot_info(angle, force)
    udp_send("SHOOT,#{angle.round(3)},#{force.round(3)}")
    done = false
    while !done
      sleep(0.1)
      response = udp_receive
      if response != :no_message
        done = true
        pp response
      end
    end
    response.first.split(',')[1]
  end

  def send_reset
    udp_send('RESET')
  end

  def test(input)
  end

  private
    def prng
      @prng ||= Random.new
    end

    def udp_socket
      return @udp_socket if @udp_socket
      @udp_socket = UDPSocket.new
      @udp_socket.connect(SERVER_IP_ADDRESS, SERVER_PORT)
      @udp_socket
    end

    def udp_send(message, check_response = true)
      udp_socket.send(message, 0)
      return unless check_response
      sleep(0.1)
      pp udp_receive
    end

    def udp_receive
      udp_socket.recvfrom_nonblock(PACKET_LENGTH)
    rescue IO::WaitReadable
      :no_message
    end

    def udp_receive_blocking
      udp_socket.recvfrom_nonblock(PACKET_LENGTH)
    rescue IO::WaitReadable
      IO.select([udp_socket])
      retry
    end

end
