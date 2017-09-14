require 'javascript_integration_test'

class PageCreationTest < JavascriptIntegrationTest

  fixtures :users, :groups, 'group/memberships'

  def test_share_with_users
    login
    prepare_page :discussion_page
    add_recipients public_user, autocomplete: true
    # hidden users do not show up in autocomplete
    add_recipients hidden_user, blocking_user
    click_on :create.t
    assert_page_users user, public_user, hidden_user
  end

  def test_set_owner
    login users(:red)
    prepare_page :discussion_page
    select 'rainbow', from: :page_owner
    click_on :create.t
    find('#banner_content').assert_text 'rainbow'
  end

  def test_share_with_groups
    login
    prepare_page :discussion_page
    # TODO: move back to fixtures
    # otherwise we have to preload the groups so they are not created during ui
    # interaction
    group
    group_to_pester
    add_recipients public_group, public_group_to_pester, autocomplete: true
    add_recipients group_to_pester
    add_recipients group
    click_on :create.t
    assert_page_groups group_to_pester, public_group_to_pester
    # can't share with group by default
    assert_no_content group.display_name
    # can't share with public_group by default
    assert_no_content public_group.display_name
    assert_page_users user
  end

  def test_add_tags
    login users(:red)
    prepare_page :discussion_page
    fill_in 'Tags', with: 'a, few, tags'
    click_on :create.t
    assert_page_tags 'a, few, tags'
  end

  protected

  def group
    records[:group] ||= FactoryGirl.create(:group)
  end

  def public_group_to_pester
    records[:public_group_to_pester] ||=
      FactoryGirl.create(:group).tap do |pester|
        pester.grant_access! public: %i[view pester]
      end
  end

  def group_to_pester
    records[:group_to_pester] ||= FactoryGirl.create(:group).tap do |pester|
      pester.grant_access! public: :pester
    end
  end

  def public_group
    records[:public_group] ||= FactoryGirl.create(:group).tap do |pub|
      pub.grant_access! public: :view
    end
  end
end
