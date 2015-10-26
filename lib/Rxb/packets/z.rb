module Rxb
    module Packets
        class Z

            def self.onTickle(user, id)
                user = Z::parseU(user)
                Rxb::Xat.write(Rxb::Xat.build_packet({
                    node: 'z',
                    elements: {
                        d: user,
                        u: "#{id}_0",
                        t: '/a_NF'
                    }
                }))

                Rxb::Xat.write_private_message(user, "Version : #{Rxb::Version::VERSION}  I'm coded in Ruby by Mars. Check how my body is made : https://github.com/Xety/Rxb :$")
            end

            def self.parseU(user)
                return user.split('_')[0]
            end

        end
    end
end
