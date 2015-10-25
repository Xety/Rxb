require 'nokogiri'
require 'nori'
require 'yaml'

module Rxb
    class Network

        def initialize()
            @nori = Nori.new(:parser => :nokogiri)

            load_config()

            login()
        end

        def load_config()
            @config = YAML::load_file(File.join(__dir__, '../../config/config.yml'))
            Rxb::Xat.load_config(@config)
        end

        def login()
            Rxb::Xat.connect('50.115.127.232', 10000)

            Rxb::Xat.write(Rxb::Xat.build_packet({
                node: 'y',
                elements: {
                    r: 8,
                    v: 0,
                    u: @config['bot']['id']
                }
            }))

            Rxb::Xat.read()

            Rxb::Xat.write(Rxb::Xat.build_packet({
                node: 'v',
                elements: {
                    n: @config['bot']['regname'],
                    p: @config['bot']['password']
                }
            }))

            packet = Rxb::Xat.read()
            @login_packets = @nori.parse(packet)

            Rxb::Xat.disconnect()

            connectToChat()
        end

        def connectToChat()
            Rxb::Xat.connect('50.115.127.232', 10021)

            Rxb::Xat.write(Rxb::Xat.build_packet({
                node: 'y',
                elements: {
                    r: @config['bot']['chat'],
                    m: 1,
                    v: 0,
                    u: @config['bot']['id'],
                    z: 759873996
                }
            }))

            loop()
        end

        def loop()
            while true
                packet = Rxb::Xat.read()

                packet.scan(/(<[\w]+[^>]*>)/) do |p|
                    hash = @nori.parse(p[0])

                    handlePacket(hash)
                end
            end
        end

        def handlePacket(packet)
            case packet.keys[0]

            when "y"
                @login_packets = @login_packets.merge packet
                Rxb::Xat.build_j2(@login_packets)

            when "m"
                if (packet['m'].has_key? "@u") && (packet['m'].has_key? "@i") && !(packet['m'].has_key? "@s") && !(packet['m'].has_key? "@p")
                    cmdPrefix = packet['m']['@t'].split('')[0]

                    if cmdPrefix == "!"
                        packet['m']['@t'] = packet['m']['@t'][1, packet['m']['@t'].length - 0]

                        message = packet['m']['@t'].split(' ')

                        case message[0]

                            when "say"
                                message.delete('say')
                                message = message.join(" ").strip

                                if message.split('')[0] == "/"
                                    Rxb::Xat.write_message("Nah.")
                                else
                                    Rxb::Xat.write_message(message)
                                end
                            when "info"
                                Rxb::Xat.write_message("Version : #{Rxb::Version::VERSION}  I'm coded in Ruby by Mars. Check how my body is made : https://github.com/Xety/Rxb :$")
                            when "memory"
                                memory = `ps -o rss -p #{$$}`.strip.split.last.to_i / 1024
                                Rxb::Xat.write_message("Memory used (Standard CMD) : #{memory} Mb")
                            else
                                Rxb::Xat.write_message("Unknown command: #{message[0]}")
                        end
                    end
                end

            else
                puts "Unknown packet: #{packet.keys[0]}"
            end
        end
    end
end
