module Rxb
    class Packet
        class << self

            PACKETS = __dir__ + '/packets/'

            def load_config(config)
                @config = config
            end

            def handlePacket(packet, network)
                case packet.keys[0]

                when "idle"
                    Rxb::Kernel::reload(File.join(PACKETS, 'packets/idle.rb'))
                    Rxb::Packets::Idle::onIdle(network)

                when "z"
                    if packet['z']['@t'] == "/l"
                        Rxb::Kernel::reload(File.join(PACKETS, 'z.rb'))
                        Rxb::Packets::Z::onTickle(packet['z']['@u'], @config['bot']['id'])
                    end

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
                    puts "Unknown packet: #{packet.keys[0]}" if @config['debug']
                end
            end

        end
    end
end
