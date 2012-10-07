require File.expand_path '../teststrap', __FILE__

class HelperTest
  attr_accessor :request
  include Rack::Picatcha::Helpers

  def initialize
    @request = HelperTest::Request.new
  end

  class Request
    attr_accessor :env
  end
end


# With "attr_accessor :request" HelperTest has "request" defined as a method
# even when @request is set to nil
#
# defined?(request)
# => method
# request
# => nil
# self
# => #<HelperTest:0x00000002125000 @request=nil>
class HelperTestWithoutRequest
  include Rack::Picatcha::Helpers
end

context "Rack::Picatcha::Helpers" do
  helper(:helper_test) { HelperTest.new }

  setup { Rack::Picatcha.public_key = '0'*40 }

  context "picatcha_tag" do

    context "ajax" do
      context "with display" do
        setup do
          mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
          helper_test.picatcha_tag(:ajax,:display => {:theme => 'red'})
        end

        asserts_topic('has js').matches %r{picatcha_ajax.js}
        asserts_topic('has div').matches %r{<div id="ajax_picatcha"></div>}
        asserts_topic('has display').matches %r{PicatchaOptions}
        asserts_topic('has theme').matches %r{"theme":"red"}
      end

      context "without display" do
        setup do
          mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
          helper_test.picatcha_tag(:ajax)
        end

        asserts_topic('has js').matches %r{picatcha_ajax.js}
        asserts_topic('has div').matches %r{<div id="ajax_picatcha"></div>}
        denies_topic('has display').matches %r{PicatchaOptions}
        denies_topic('has theme').matches %r{"theme":"red"}
      end
    end

    context "noscript" do
      setup do
        mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
        helper_test.picatcha_tag :noscript, :public_key => "hello_world_world", :language => :en
      end

      asserts_topic("iframe").matches %r{iframe}
      asserts_topic("no script tag").matches %r{<noscript>}
      asserts_topic("public key").matches %r{hello_world_world}
      asserts_topic("has language").matches %r{hl=en}
      denies_topic("has js").matches %r{picatcha_ajax.js}
    end

    context "challenge" do
      setup do
        mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
        helper_test.picatcha_tag(:challenge, :language => :en)
      end

      asserts_topic("has script tag").matches %r{script}
      asserts_topic("has challenge js").matches %r{challenge}
      denies_topic("has js").matches %r{picatcha_ajax.js}
      denies_topic("has display").matches %r{PicatchaOptions}
      asserts_topic("has public_key").matches %r{#{'0'*40}}
      asserts_topic("has language").matches %r{hl=en}
    end

    context "server" do

      asserts("using ssl url") do
        mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
        helper_test.picatcha_tag(:challenge, :ssl => true)
      end.matches %r{#{Rack::Picatcha::API_SECURE_URL}}

      asserts("using non ssl url") do
        mock(helper_test.request.env).[]('picatcha.msg').returns(nil)
        helper_test.picatcha_tag(:ajax)
      end.matches %r{#{Rack::Picatcha::API_URL}}
    end

  end

  context "picatcha_tag_errors" do
    context "challenge with error" do
      setup do
        mock(helper_test.request.env).[]('picatcha.msg').returns("Sample Error")
        helper_test.picatcha_tag(:challenge)
      end

      asserts_topic("has script tag").matches %r{script}
      asserts_topic("has challenge js").matches %r{challenge}
      denies_topic("has js").matches %r{picatcha_ajax.js}
      denies_topic("has display").matches %r{PicatchaOptions}
      asserts_topic("has public_key").matches %r{#{'0'*40}}
      asserts_topic("has previous error").matches %r{Sample%20Error}
    end

    context "noscript with error" do
      setup do
        mock(helper_test.request.env).[]('picatcha.msg').returns("Sample Error")
        helper_test.picatcha_tag :noscript, :public_key => "hello_world_world"
      end

      asserts_topic("iframe").matches %r{iframe}
      asserts_topic("no script tag").matches %r{<noscript>}
      asserts_topic("public key").matches %r{hello_world_world}
      denies_topic("has js").matches %r{picatcha_ajax.js}
      asserts_topic("has previous error").matches %r{Sample%20Error}
    end

  end

  context "picatcha_valid?" do

    asserts "that it passes when picatcha.valid is true" do
      Rack::Picatcha.test_mode = nil
      mock(helper_test.request.env).[]('picatcha.valid').returns(true)
      helper_test.picatcha_valid?
    end

    denies "that it passes when picatcha.valid is false" do
      Rack::Picatcha.test_mode = nil
      mock(helper_test.request.env).[]('picatcha.valid').returns(false)
      helper_test.picatcha_valid?
    end

    asserts "that it passes when test mode set to pass" do
      Rack::Picatcha.test_mode!
      helper_test.picatcha_valid?
    end

    denies "that it passes when test mode set to fail" do
      Rack::Picatcha.test_mode! :return => false
      helper_test.picatcha_valid?
    end

  end
end


context Rack::Picatcha::Helpers do
  helper(:helper_test) { HelperTestWithoutRequest.new }
    context "request object not available.  Rack-picatcha shouldn't die" do
      setup do
        helper_test.picatcha_tag(:challenge)
      end

      asserts_topic("has script tag").matches %r{script}
      asserts_topic("has challenge js").matches %r{challenge}
      denies_topic("has js").matches %r{picatcha_ajax.js}
      denies_topic("has display").matches %r{PicatchaOptions}
      asserts_topic("has public_key").matches %r{#{'0'*40}}
    end
end
