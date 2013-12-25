module NinjaBlocks
  class User < Base
    def info
      get('/user')
    end

    def stream
      get('/user/stream')
    end

    def pusher_channel
      get('/user/pusherchannel')
    end
  end
end


