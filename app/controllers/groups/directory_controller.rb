class Groups::DirectoryController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :authorization_required
  before_filter :set_default_path

  stylesheet 'directory'
  helper 'groups/directory'
  permission_helper 'groups/structures'

  def index
    @groups = groups_to_display.order(:name).paginate(pagination_params)
  end

  protected

  def set_default_path
    if params[:path].empty?
      params[:path] = default_path
    end
  end

  def default_path
    if logged_in? && current_user.groups.any?
      'my'
    else
      'search'
    end
  end

  helper_method :my_groups?

  def my_groups?
    logged_in? && params[:path].start_with?('my')
  end

  def groups_to_display
    if search_filter
      visible_groups.named_like("#{search_filter}%")
    else
      promoted_groups
    end
  end

  def visible_groups
    if my_groups?
      current_user.primary_groups_and_networks
    else
      Group.with_access(current_user => :view)
    end
  end

  def promoted_groups
    if my_groups?
      visible_groups
    else
      visible_groups.none
    end
  end

  def search_filter
    return @filter if defined?(@filter)
    @filter = get_filter_from_params
  end

  def get_filter_from_params
    if params[:name].present?
      params[:name]
    elsif params[:path].include? 'search/'
      params[:path].sub(/.*search\//, '')
    end
  end
end

