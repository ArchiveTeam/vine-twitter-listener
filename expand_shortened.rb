require 'typhoeus'

module ExpandShortened
  def get_tcos_from_tweet(text)
    text.scan(%r{https?://t.co/[a-zA-Z0-9_-]+})
  end

  def expand_tcos(tcos)
    hydra = Typhoeus::Hydra.hydra
    expanded = []

    tcos.each do |tco|
      req = Typhoeus::Request.new(tco, method: :head).tap do |req|
        req.on_headers do |resp|
          if !resp.headers['location']
            raise 'expected to find location header, but did not find it'
          end

          expanded << resp.headers['location']
        end
      end

      hydra.queue(req)
    end

    hydra.run

    expanded
  end
end
