module Rxb
    module Packets
        class Idle

            def self.onIdle(user, id)
                Rxb::Xat.write_message("Need to reconnect, brb.")
                Rxb::Network.connectToChat()
            end
        end
    end
end
