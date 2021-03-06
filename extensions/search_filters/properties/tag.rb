SearchFilter.new('/tag/:tag_name/') do
  query do |query, tag_name|
    query.add_tag_constraint(tag_name)
  end

  #
  # ui
  #
  self.path_order = 100
  self.section = :properties
  self.singleton = false
  self.description = :filter_tag_description

  #
  # this gets invoked in the view with instance_eval, so it has the
  # view's variables.
  #
  html(delayed: true, submit_button: false) do
    ret = content_tag(:p) do
      content_tag(:strong, :tag.tcap) + ' ' +
        text_field_tag('tag_name', nil, class: 'form-control', onkeydown: submit_form('page_search_form'))
    end
    ret += "\n"

    # TODO: This means that we get the tags when loading the group or
    # user page list. Instead, could we only figure out/load the tags if
    # the user does a search by tag? It would be quicker, but maybe not
    # enough to matter?
    source = @user if @user == current_user
    source ||= @group
    tags_to_show = Page::TagSuggestions.new(source, current_user).all

    tags = tag_cloud(tags_to_show) do |tag, css_class|
      link_to_page_search tag.name, { tag_name: tag.name }, class: css_class
    end
    ret += if tags
             safe_join(tags, ' ')
           else
             :no_things_found.t things: :tags.t
           end
    ret
  end

  label do |opts|
    tag_name = opts[:tag_name]
    if tag_name.empty?
      :tag.t + '...'
    elsif tag_name.length > 15
      "#{:tag.t}: #{tag_name[0..14]}..."
    else
      "#{:tag.t}: #{tag_name}"
    end
  end
end
