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
            Rxb::Packet.load_config(@config)
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
                        Rxb::Xat.build_j2(@login_packets)
                    else
                        Rxb::Packet.handlePacket(hash)
                    end
                end
            end
        end
    end
end
