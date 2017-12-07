require_relative 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  def test_get_permissions
    image_assets_are_private
    asset = FactoryBot.create :image_asset
    assert_permission_denied do
      get :show, id: asset.id, path: asset.basename
    end
  end

  def test_get_with_escaped_chars
    image_assets_are_private
    @controller.stubs(:authorized?).returns(true)
    asset = FactoryBot.create :image_asset
    get :show, id: asset.id, path: asset.basename + '\xF3'
    assert_response :success
  end

  def test_not_found
    assert_raises ActiveRecord::RecordNotFound do
      get :show, id: :non_existant
    end
  end

  def test_not_found_with_version
    assert_raises ActiveRecord::RecordNotFound do
      get :show, id: :non_existant, version: 123
    end
  end

  def test_thumbnail_get
    image_assets_are_private
    asset = FactoryBot.create :image_asset
    @controller.stubs(:authorized?).returns(true)
    @controller.expects(:private_filename).returns(asset.private_filename)
    get :show, id: asset.id, path: asset.basename
    @controller.expects(:private_filename).returns(thumbnail(asset.private_filename))
    get :show, id: asset.id, path: thumbnail(asset.basename)
  end

  def test_destroy
    user = FactoryBot.create :user
    page = FactoryBot.create :page, created_by: user
    asset = page.add_attachment! uploaded_data: upload_data('photo.jpg')
    user.updated(page)
    login_as user
    assert_difference 'page.assets.count', -1 do
      delete :destroy, id: asset.id, page_id: page.id
    end
  end

  private

  def thumbnail(path)
    ext = File.extname(path)
    path.sub(/#{ext}$/, "_small#{ext}")
  end

  def image_assets_are_private
    Asset::Image.any_instance.stubs(:public?).returns(false)
  end
end
