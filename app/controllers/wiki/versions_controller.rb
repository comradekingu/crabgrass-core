class Wiki::VersionsController < Wiki::BaseController
  guard revert: :may_revert_wiki_version?,
        destroy: :may_admin_wiki?

  def show
    # unless request.xhr?
    #  params[:page] = @wiki.page_for_version(@version)
    #  @versions = @wiki.versions.most_recent.paginate(pagination_params)
    # end
  end

  def index
    @versions = @wiki.versions.most_recent.paginate(pagination_params)
  end

  def revert
    @wiki.revert_to_version(@version, current_user)
    redirect_to wiki_versions_path(@wiki)
  end

  # def destroy
  #  what happened to this code?
  # end

  protected

  # making sure the version is available for the permission
  def fetch_wiki
    super
    return if action? :index
    @version = @wiki.find_version(params[:id])
    @former = @wiki.find_version(params[:id].to_i - 1) if params[:id].to_i > 1
  rescue Wiki::VersionNotFoundError => ex
    error ex
    redirect_to action: :index
  end
end
