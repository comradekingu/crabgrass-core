module ProfileHelper

  def edit_profile_link
      link_to :edit_profile_link.t, edit_me_profile_path
  end

  def banner_field(formy)
    formy.heading :banner.t

    if @profile.picture
      formy.row(class: :current_banner) do |r|
        r.input picture_tag(@profile.picture, banner_geometry)
      end
    end
    formy.row do |r|
      r.label I18n.t(:file)
      r.label_for 'profile_picture_upload'
      r.input file_field_tag('profile[picture][upload]',
                             id: 'profile_picture_upload')
      r.info :banner_info.t(
        optimal_dimensions: "#{banner_width} x #{banner_height}"
      )
    end
  end
end
