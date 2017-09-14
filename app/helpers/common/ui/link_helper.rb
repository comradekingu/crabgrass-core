#
# Here lies many helpers for making links
#

module Common::Ui::LinkHelper
  # link to if and only if...
  # like link_to_if, but return nil if the condition is false
  # not widely used. candidate for purging.
  # def link_to_iff(condition, name, options = {}, html_options = {}, &block)
  #  if condition
  #    link_to(name, options, html_options, &block)
  #  else
  #    nil
  #  end
  # end

  ##
  ## FORMS
  ##

  def submit_link(label, options = {})
    name = options.delete(:name) || 'commit'
    value = options.delete(:value) || label
    accesskey = shortcut_key label
    onclick = %<submitForm(this, "#{name}", "#{value}");>
    if options[:confirm]
      onclick = %<if(confirm("#{options[:confirm]}")){#{onclick};}else{return
 false;}>
    end
    %(<span class='#{options[:class]}'><a href='#' onclick='#{onclick}' style
='#{options[:style]}' class='#{options[:class]}' accesskey='#{accesskey}'>#{label}</a></span>).html_safe
  end

  # looks like a link but is a form so people with no-script can still
  # logout.
  def logout_link
    button_to :menu_link_logout.t(user: current_user.display_name),
              logout_path,
              method: :post, class: 'btn btn-link tab'
  end
  ##
  ## UTILITY
  ##

  ## makes this: link | link | link
  def link_line(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:div, links.compact.join(char).html_safe, class: 'link_line')
  end

  def link_span(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:span, links.compact.join(char).html_safe, class: 'link_line')
  end

  ##
  ## ACTIVE LINKS
  ##

  # just like link_to, but sets the <a> tag to have class 'active'
  # if last argument is true or if the url is in the form of a hash
  # and the current params match this hash.
  # TODO: the signature of this helper should be changed to match that
  # of link_to_remote_active.
  def link_to_active(link_label, url_hash, active = nil, html_options = {})
    active ||= url_active?(url_hash)
    selected_class = active ? 'active' : ''
    classes = [selected_class, html_options[:class]]
    html_options[:class] = classes.join(' ')
    link_to(link_label, url_hash, html_options)
  end

  # like link_to_remote, but sets the class to be 'active' if the link is
  # active (:active => true)
  def link_to_remote_active(link_label, options, html_options = {})
    active = options.delete(:active) || html_options.delete(:active)
    selected_class = active ? 'active' : ''
    html_options[:class] = [html_options[:class], selected_class].combine
    if options[:icon] or html_options[:icon]
      link_to_remote_with_icon(link_label, options, html_options)
    else
      link_to_remote(link_label, options, html_options)
    end
  end

  ##
  ## WIDGET LINKS
  ##

  #
  # Creates a link to hide and show an html element.
  # Requires javascript.
  #
  # two forms:
  #
  #  link_to_toggle('link label', element_id, options)
  #
  #  link_to_toggle('link label', options) do
  #    ... html ..
  #  end
  #
  # options:
  # * :icon -- replace the default icon
  # * :open -- if true, the toggle area will start opened instead of closed.
  # * :onvisible -- javascript to execute when opening the element.
  #
  def link_to_toggle(label, *args, &block)
    options = args.extract_options!
    id = args.pop || label.nameize + '-toggle-area'

    if options[:open]
      options[:icon] ||= 'sort_down'
      style = ''
    else
      options[:icon] ||= 'right'
      style = 'display:none'
    end

    if block_given?
      link_to_toggle_without_block(label, id, options) +
        content_tag(:div, capture(&block), id: id, style: style)
    else
      link_to_toggle_without_block(label, id, options)
    end
  end

  def link_to_toggle_without_block(label, id, options = {})
    function = if options[:onvisible]
                 format('fn = function(){%s}; ', options[:onvisible])
               else
                 'fn = null; '
               end
    function += "linkToggle(eventTarget(event), '#{id}', fn)"
    link_to_function label, function, options
  end

  #  # makes an icon button to a remote action. when you click on the icon, it turns
  #  # into a spinner. when done, the icon returns. any id passed to html_options
  #  # is passed on the icon, and not the <a> tag.
  #  def link_to_remote_icon(icon, options={}, html_options={})
  #    icon_options = {
  #      :loading => "event.target.blur();" + spinner_icon_on(icon),
  #      :complete => "event.target.blur();" + spinner_icon_off(icon)
  #    }
  #    link_to_remote(
  #      pushable_icon_tag(icon,16,html_options.delete(:id)),
  #      options.merge(icon_options),
  #      html_options
  #    )
  #  end
  #  def link_to_function_icon(icon, function, html_options={})
  #    link_to_function(
  #      pushable_icon_tag(icon),
  #      function,
  #      html_options
  #    )
  #  end

  private

  def shortcut_key(label)
    label.gsub!(/\[(.)\]/, '<u>\1</u>')
    /<u>(.)<\/u>/.match(label).to_a[1]
  end

  def link_char(links)
    if links.first.is_a? Symbol
      char = links.shift
      return ' &bull; '.html_safe if char == :bullet
      return ' ' if char == :none
      ' | '
    else
      ' | '
    end
  end
end
