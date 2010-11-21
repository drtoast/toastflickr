require 'test_helper'

class PhotosetsControllerTest < ActionController::TestCase
  setup do
    @photoset = photosets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:photosets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create photoset" do
    assert_difference('Photoset.count') do
      post :create, :photoset => @photoset.attributes
    end

    assert_redirected_to photoset_path(assigns(:photoset))
  end

  test "should show photoset" do
    get :show, :id => @photoset.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @photoset.to_param
    assert_response :success
  end

  test "should update photoset" do
    put :update, :id => @photoset.to_param, :photoset => @photoset.attributes
    assert_redirected_to photoset_path(assigns(:photoset))
  end

  test "should destroy photoset" do
    # TODO: FIXME
    # assert_difference('Photoset.count', -1) do
    #   delete :destroy, :id => @photoset.to_param
    # end
    # 
    # assert_redirected_to photosets_path
  end
end
