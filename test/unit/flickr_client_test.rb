require 'test_helper'

class FlickrClientTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  setup do
    @client = Flickr::Client.new
    @user = users(:drtoast)
  end
  
  test "should get user info" do
    username, realname, url = @client.get_info(@user.flickr_user_id)
    assert_equal @user.username, username
    assert_equal @user.realname, realname
    assert_equal @user.url, url
  end
  
  test "should get user tags" do
    tags = @client.get_tags(@user.flickr_user_id)
    assert tags.include?('red')
  end
  
  test "should get user sets and process in a block" do
    found = false
    @client.get_sets(@user.flickr_user_id) do |set|
      found = true if set[:title] == 'Burning Man 2005'
    end
    assert found
  end
end
