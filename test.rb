ENV['RACK_ENV'] = 'test'

require_relative 'saml_inspect'
require 'test/unit'
require 'rack/test'
require 'erb'
require 'ostruct'

def render_erb(template_file, locals=nil)
  fp = File.read(template_file)
  ERB.new(fp).result(OpenStruct.new(locals).instance_eval { binding })
end

class SamlInspectTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SamlInspect
  end

  def test_get_root
    get '/'
    assert last_response.ok?
    assert_equal render_erb('views/index.erb'), last_response.body
  end

end
