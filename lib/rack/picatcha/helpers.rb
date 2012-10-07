require 'json'

module Rack
  class Picatcha
    module Helpers

      DEFAULT= {
        :height => 300,
        :width => 500,
        :row => 3,
        :cols => 5,
        :format => '2',
        :style => '#2a1f19',
        :link => '1',
        :img_size => '75',
        :noise_level => '2',
        :noise_type => '0',
        :lang => 'en',
        :lang_override => '0',
        :ssl => false
      }

      # Helper method to output a picatcha form. Some of the available
      # types you can have are:
      #
      # :challenge - Returns a javascript picatcha form
      # :noscript  - Return a non-javascript picatcha form
      # :ajax      - Return a ajax picatcha form
      #
      # You also have a few available options:
      #
      # For :challenge and :noscript
      #  :public_key - Set the public key. Overrides the key set in Middleware option
      def picatcha_tag(type= :noscript, options={})
        # Default options
        options = DEFAULT.merge(options)
        options[:public_key] ||= Rack::Picatcha.public_key
        path = options[:ssl] ? Rack::Picatcha::API_SECURE_URL : Rack::Picatcha::API_URL
 
        raise PicatchaError, "No public key specified." unless options[:public_key].to_s != ''
        error = options[:error] ||= (defined? flash ? flash[:picatcha_error] : "")
        html  = ""
        elm_id = "picatcha"
  
        html << <<-EOS
            <script type="text/javascript" src="#{path}/static/client/jquery.min.js"></script>
            <script type="text/javascript" src="#{path}/static/client/picatcha.js"></script>
            <link href="#{path}/static/client/picatcha.css" rel="stylesheet" type="text/css">
            <script>Picatcha.PUBLIC_KEY="#{options[:public_key]}";
Picatcha.setCustomization({"format":"#{options[:format]}","color":"#{options[:style]}","link":"#{options[:link]}","image_size":"#{options[:img_size]}","lang":"#{options[:lang]}","langOverride":"#{options[:lang_override]}","noise_level":"#{options[:noise_level]}","noise_type":"#{options[:noise_type]}"});
window.onload=function(){Picatcha.create("#{elm_id}", {});};</script>
            <div id="#{elm_id}"></div>
        EOS

        if options[:display]
          %{<script type="text/javascript">
            var PicatchaOptions = #{options[:display].to_json};
            </script>}.gsub(/^ +/, '')
        else
          ''
        end + html
      end

      # Helper to return whether the picatcha was accepted.
      def picatcha_valid?(options={})
#        LOGGER.debug "def picatchs_valid? options=#{options}"
        picatchadata = options[:picatcha] || ""
        private_key = options[:private_key] || Rack::Picatcha.private_key
        if picatchadata.to_s == "" then
          test = Rack::Picatcha.test_mode
          test.nil? ? request.env['picatcha.valid'] : test
        else
          retval, msg = Rack::Picatcha.verify_picatcha({
            :private_key => private_key,
            :ipaddr => request.ip,
            :picatcha => picatchadata
          })
          return retval
        end
      end

      private

      def uri_parser
        @uri_parser ||= URI.const_defined?(:Parser) ? URI::Parser.new : URI
      end

    end
  end
end
