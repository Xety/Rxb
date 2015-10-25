require "nokogiri"
require "nori"
require "date"
require "yaml"

module Rxb
    class Network

        def initialize()
            @nori = Nori.new(:parser => :nokogiri)

            load_config()

            login()
        end

        def load_config()
            @config = YAML::load_file(File.join(__dir__, '../../config/config.yml'))
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

                    if hash.has_key? "y"
                        @login_packets = @login_packets.merge hash

                        Rxb::Xat.write(Rxb::Xat.build_packet({
                            node: 'j2',
                            elements: {
                                cb: Time.now.to_i,
                                Y: 2,
                                l5: 65535,
                                l4: rand(10...500),
                                l3: rand(10...500),
                                l2: 0,
                                q: 1,
                                y: @login_packets['y']['@i'],
                                k: @login_packets['v']['@k1'],
                                k3: @login_packets['v']['@k3'],
                                z: 12,
                                p: 0,
                                c: @config['bot']['chat'],
                                r: '',
                                f: 0,
                                e: 1,
                                u: @login_packets['v']['@i'],
                                d0: @login_packets['v']['@d0'],
                                d3: @login_packets['v']['@d3'],
                                dt: @login_packets['v']['@dt'],
                                N: @login_packets['v']['@n'],
                                n: @config['bot']['name'],
                                a: @config['bot']['avatar'],
                                h: @config['bot']['homepage'],
                                v: 'Ruby <3'
                            }
                        }))
                    else
                        handlePacket(hash)
                    end
                end
            end
        end

        def handlePacket(packet)
            case packet.keys[0]

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
                                        Rxb::Xat.write(Rxb::Xat.build_packet({
                                            node: 'm',
                                            elements: {
                                                t: "Nah.",
                                                u: @config['bot']['id']
                                            }
                                        }))
                                    else
                                        Rxb::Xat.write(Rxb::Xat.build_packet({
                                            node: 'm',
                                            elements: {
                                                t: message,
                                                u: @config['bot']['id']
                                            }
                                        }))
                                    end
                                when "info"
                                    Rxb::Xat.write(Rxb::Xat.build_packet({
                                        node: 'm',
                                        elements: {
                                            t: "I'm coded in Ruby by Mars. Check how my body is made : https://github.com/Xety/BotRuby :$",
                                            u: @config['bot']['id']
                                        }
                                    }))
                                when "memory"
                                    memory = `ps -o rss -p #{$$}`.strip.split.last.to_i / 1024
                                    Rxb::Xat.write_message("Memory used (Standard CMD) : #{memory} Mb", @config['bot']['id'])
                                else
                                    Rxb::Xat.write_message("Unknown command: #{message[0]}", @config['bot']['id'])
                            end
                        end
                    end

                else
                    puts "Unknown packet: #{packet.keys[0]}"
            end
        end
    end
end
