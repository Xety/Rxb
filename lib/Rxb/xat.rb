require 'socket'
require 'date'

module Rxb
    class Xat
        class << self

            def load_config(config)
                @config = config
            end

            def connect(ip, port)
                @socket = TCPSocket.open(ip, port)
            end

            def write(message)
                puts "--> #{message}" if @config['debug']

                @socket.write(message + 0.chr)
            end

            def read()
                response =  @socket.recv(2048)

                if !response.empty?

                    #We need to read the socket 2 times at the connection because xat send a loooooot of packets. (Specially the old messages)
                    if response.strip[-1, 1] != '>'
                        response << @socket.recv(2048)
                    end

                    puts "<-- #{response}" if @config['debug']

                    return response.chomp
                end

                return nil
            end

            def disconnect()
                @socket.close
            end

            def build_j2(packet)
                j2 = { cb: Time.now.to_i }

                j2[:Y] = 2 if (packet['y'].has_key? '@au')

                j2 = j2.merge({
                    l5: 65535,
                    l4: rand(10...500),
                    l3: rand(10...500),
                    l2: 0,
                    q: 1,
                    y: packet['y']['@i'],
                    k: packet['v']['@k1'],
                    k3: packet['v']['@k3']
                })

                j2[:d1] = packet['v']['@d1'] if (packet['v'].has_key? '@d1')

                j2 = j2.merge({
                    z: 12,
                    p: 0,
                    c: @config['bot']['chat'],
                    r: '',
                    f: 0,
                    e: 1,
                    u: packet['v']['@i'],
                    d0: packet['v']['@d0']
                })

                2.upto(15) do |x|
                    if packet['v'].has_key? "@d#{x.to_s}"
                        j2["d#{x.to_s}"] = packet['v']["@d#{x.to_s}"]
                    end
                end

                j2[:dO] = packet['v']['@dO'] if (packet['v'].has_key? '@dO')
                j2[:dx] = packet['v']['@dx'] if (packet['v'].has_key? '@dx')
                j2[:dt] = packet['v']['@dt'] if (packet['v'].has_key? '@dt')

                j2 = j2.merge({
                    N: packet['v']['@n'],
                    n: @config['bot']['name'],
                    a: @config['bot']['avatar'],
                    h: @config['bot']['homepage'],
                    v: 'Ruby <3'
                })

                write(build_packet({
                    node: 'j2',
                    elements: j2
                }))
            end

            def build_packet(data)
                string = ''

                data[:elements].each do |key, value|
                   string += key.to_s + '="' + data[:elements][key].to_s + '" ';
                end

                string = '<' + data[:node] + ' ' + string + '/>'
                return string
            end

            def write_message(message)
                write(build_packet({
                    node: 'm',
                    elements: {
                        t: message,
                        u: @config['bot']['id']
                    }
                }))
            end

            def write_private_message(user, message)
                write(build_packet({
                    node: 'p',
                    elements: {
                        u: user,
                        t: message
                    }
                }))
            end

            def write_private_conversation(user, message)
                write(build_packet({
                    node: 'p',
                    elements: {
                        u: user,
                        t: message,
                        s: 2,
                        d: @config['bot']['id']
                    }
                }))
            end
        end
    end
end
