module Rxb
    module Packets
        class Idle

            def self.onIdle(network)
                network.connectToChat
            end

        end
    end
end
