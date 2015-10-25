require 'socket'

module Rxb
    class Xat
        class << self

            def connect(ip, port)
                @socket = TCPSocket.open(ip, port)
            end

            def write(message)
                puts "--> #{message}"

                @socket.write(message + 0.chr)
            end

            def read()
                response =  @socket.recv(1024)

                if !response.empty?
                    puts "<-- #{response}"

                    return response.chomp
                end

                return nil
            end

            def disconnect()
                @socket.close
            end

            def build_packet(data)
                string = ''

                data[:elements].each do |key, value|
                   string += key.to_s + '="' + data[:elements][key].to_s + '" ';
                end

                string = '<' + data[:node] + ' ' + string + '/>'
                return string
            end

            def write_message(message, id)
                write(build_packet({
                    node: 'm',
                    elements: {
                        t: message,
                        u: id
                    }
                }))
            end
        end
    end
end
