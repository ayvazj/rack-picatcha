require  File.expand_path '../picatcha/helpers', __FILE__
require 'net/http'

module Rack
  class Picatcha
    API_URL         = 'http://api.picatcha.com'
    API_SECURE_URL  = 'https://api.picatcha.com'
    VERIFY_URL      = 'http://api.picatcha.com/v'
    CHALLENGE_FIELD = 'picatcha'

    SKIP_VERIFY_ENV = ['test', 'cucumber']

    class << self
      attr_accessor :private_key, :public_key, :test_mode, :proxy_host, :proxy_port, :proxy_user, :proxy_password

      def test_mode!(options = {})
        value = options[:return]
        self.test_mode = value.nil? ? true : options[:return]
      end
    end

    # Initialize the Rack Middleware. Some of the available options are:
    #   :public_key  -- your Picatcha API public key *(required)*
    #   :private_key -- your Picatcha API private key *(required)*
    #
    def initialize(app,options = {})
      @app = app
      @paths = options[:paths] && [options[:paths]].flatten.compact
      self.class.private_key = options[:private_key]
      self.class.public_key = options[:public_key]
      self.class.proxy_host = options[:proxy_host]
      self.class.proxy_port = options[:proxy_port]
      self.class.proxy_user = options[:proxy_user]
      self.class.proxy_password = options[:proxy_password]
    end

    def call(env)
#        LOGGER.debug "def call"
      dup._call(env)
    end

    def _call(env)
      request = Request.new(env)
#      LOGGER.debug "def _call env=#{env} params=#{request.params}"
      if request.params[CHALLENGE_FIELD]
        value, msg = verify({
          :request => request,
          :ip => request.ip,
          :challenge => request.params[CHALLENGE_FIELD]
        })
        env.merge!('picatcha.valid' => value == 'true', 'picatcha.msg' => msg)
      end
      @app.call(env)
    end

    def verify(options = {})
      if !options.is_a? Hash
        options = {:model => options}
      end

      model = options[:model]
      request = options[:request]

      return Rack::Picatcha.verify_picatcha({
          :private_key => Rack::Picatcha.private_key,
          :ipaddr => request.ip,
          :proxy_host => self.class.proxy_host,
          :proxy_port => self.class.proxy_port,
          :proxy_user => self.class.proxy_user,
          :proxy_password => self.class.proxy_password,
          :picatcha => request.params["picatcha"]
      })
    end

    def self.verify_picatcha(options = {})
      if !options.is_a? Hash
        options = {:model => options}
      end

      ipaddr = options[:ipaddr]
      proxy_host = options[:proxy_host]
      proxy_port = options[:proxy_port]
      proxy_user = options[:proxy_user]
      proxy_password = options[:proxy_password]

      private_key = options[:private_key]
      picatchadata = options[:picatcha]

      data = {
        "k" => private_key,
        "ip" => ipaddr,
        "ua"=> "Rack-Picatcha Ruby Gem",
        "s" => picatchadata[:stages],  #the number of stages
        "t" => picatchadata[:token],   #the challenge token
        "r" => picatchadata[:r]        #the array of images
      }
       
      payload = data.to_json
#      LOGGER.debug "payload = #{payload}"

      uri  = URI.parse(VERIFY_URL)
      http = Net::HTTP.start(uri.host, uri.port)

      if proxy_host && proxy_port
        http = Net::HTTP.Proxy(proxy_host,
                               proxy_port,
                               proxy_user,
                               proxy_password).start(uri.host, uri.port)
      end

      request           = Net::HTTP::Post.new(uri.path)
      request.body      = payload
      response          = http.request(request)

      # debugging info
#      LOGGER.debug "response.body = #{response.body}"
          
      if response.body !=nil
        parsed_json = JSON(response.body)
      else
        return false, 'No reponse captured'
      end
          
#      LOGGER.error "error? = #{parsed_json["e"]}"
          
      error = parsed_json["e"]
          
      # so far just a simple if.. else to check if the picatcha was 
      # solved correctly. will revisit later and make it more
      # verbose
      if parsed_json["s"]==true
        return true, ""
      else
        message = "Sorry, you incorrectly filled out Picatcha. Please try again."
        message = I18n.translate(:'picatcha.errors.verification_failed', :default => message) if defined?(I18n)
        return false, message
      end
    end
  


  
    class PicatchaError < StandardError
    end
  end
end
