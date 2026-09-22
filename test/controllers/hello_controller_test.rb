require "test_helper"

class HelloControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_select "img.codespaces-logo"
  end
end
