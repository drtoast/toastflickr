require 'test_helper'

class PhotosetPhotosControllerTest < ActionController::TestCase
  setup do
    @photoset_photo = photoset_photos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:photoset_photos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create photoset_photo" do
    assert_difference('PhotosetPhoto.count') do
      post :create, :photoset_photo => @photoset_photo.attributes
    end

    assert_redirected_to photoset_photo_path(assigns(:photoset_photo))
  end

  test "should show photoset_photo" do
    get :show, :id => @photoset_photo.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @photoset_photo.to_param
    assert_response :success
  end

  test "should update photoset_photo" do
    put :update, :id => @photoset_photo.to_param, :photoset_photo => @photoset_photo.attributes
    assert_redirected_to photoset_photo_path(assigns(:photoset_photo))
  end

  test "should destroy photoset_photo" do
    assert_difference('PhotosetPhoto.count', -1) do
      delete :destroy, :id => @photoset_photo.to_param
    end

    assert_redirected_to photoset_photos_path
  end
end
