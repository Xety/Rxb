module Rxb
    module Kernel
        def self.reload(lib)
            if old = $LOADED_FEATURES.find{|path| path=~/#{Regexp.escape lib}(\.rb)?\z/ }
                load old
            else
                require lib
            end
        end
    end
end
