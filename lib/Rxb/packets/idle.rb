module Rxb
    module Packets
        class Idle

            def self.onIdle(network)
                Rxb::Xat.write_message("Need to reconnect, brb.")
                network.connectToChat
            end

        end
    end
end
