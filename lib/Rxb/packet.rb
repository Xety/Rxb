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
                    Rxb::Kernel::reload(File.join(PACKETS, 'idle.rb')) unless defined?(Rxb::Packets::Idle)
                    Rxb::Packets::Idle::onIdle(network)

                when "z"
                    if packet['z']['@t'] == "/l"
                        Rxb::Kernel::reload(File.join(PACKETS, 'z.rb')) unless defined?(Rxb::Packets::Z)
                        Rxb::Packets::Z::onTickle(packet['z']['@u'], @config['bot']['id'])
                    end

                when "m"
                    message = {}
                    message[:message] = packet['m']['@t']

                    #Ignore all commands message starting with / (Like deleting a message, Typing etc).
                    if !(message.has_key? :message) || (message[:message].split('')[0] == '/')
                        return
                    end

                    #Xat send sometimes the old messages, we ignore it so.
                    if (packet['m'].has_key? "@s")
                        return
                    end

                    if !(packet['m'].has_key? "@i") || !(packet['m'].has_key? "@u") || (packet['m'].has_key? "@p")
                        return
                    end


                    cmdPrefix = packet['m']['@t'].split('')[0]

                    if cmdPrefix != "!"
                        return
                    end

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

                        when "reload"
                            message.delete('reload')

                            if message.any?
                                if !File.exist?(PACKETS + "#{message[0]}.rb")
                                    Rxb::Xat.write_message("The packet #{message[0]} doesn't exist.")
                                    return
                                end

                                begin
                                    Rxb::Kernel::reload(File.join(PACKETS, "#{message[0]}.rb"))
                                    Rxb::Xat.write_message("The packet #{message[0]} has been reloaded successfully.")
                                rescue
                                    Rxb::Xat.write_message("Error to reload the packet #{message[0]}.")
                                end
                            end

                        when "load"
                            message.delete('load')

                            if message.any?
                                if !File.exist?(PACKETS + "#{message[0]}.rb")
                                    Rxb::Xat.write_message("The packet #{message[0]} doesn't exist.")
                                    return
                                end

                                if defined?(Object::const_get("Rxb::Packets::#{message[0].capitalize}"))
                                    Rxb::Xat.write_message("The packet #{message[0]} has already been loaded.")
                                else
                                    Rxb::Kernel::reload(File.join(PACKETS, "#{message[0]}.rb"))
                                    Rxb::Xat.write_message("The packet #{message[0]} has been loaded successfully.")
                                end
                            end

                        else
                            Rxb::Xat.write_message("Unknown command: #{message[0]}")
                    end

                else
                    puts "Unknown packet: #{packet.keys[0]}" if @config['debug']
                end
            end

        end
    end
end
