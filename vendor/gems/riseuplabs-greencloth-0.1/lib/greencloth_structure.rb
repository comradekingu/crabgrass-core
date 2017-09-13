#
# Handles creating an outline of the wiki body, and generating a table of contents
# from this data.
#
#

require File.dirname(__FILE__) + '/green_tree'

module GreenclothStructure
  def section_names
    green_tree.section_names
  end

  # returns the tree of headings
  # if this is called after to_html, we use the already existing @headings
  # but be warned that to_html will mangled the string and it will not the
  # original!
  def green_tree
    if @green_tree
      @green_tree
    else
      extract_headings
      @green_tree = convert_to_tree(@headings)
    end
  end

  protected

  # called by the formatter whenever it encounters h1..h4 tags
  def add_heading(indent, text)
    text = extract_offtags(text.dup)
    # strip ALL markup, modifies variable text.
    formatter.clean_html(text, {})
    @headings ||= []
    @heading_names ||= {}
    if text
      name = text.nameize
      name = find_available_name(@heading_names, name) if @heading_names[name]
      @heading_names[name] = true # mark as taken
      @headings << [indent, text, name]
    end
    name
  end

  # called by greencloth when [[toc]] is encountered
  def symbol_toc
    # make sure to generate the green tree from the original markup, not the filtered markup
    @green_tree = GreenCloth.new(@original_markup).green_tree
    generate_toc_html(@green_tree, 1)
  end

  private

  #
  # converts an array with heading numbers and values into a nested tree.
  #
  # INPUT:
  #   number = 1
  #   array = [[1, "Fruits", "fruits"], [2, "Apples", "apples"],
  #             [2, "Pears", "pears"], [1, "Vegetables", "vegetables"], [2, "Green Beans", "green-beans"]]
  # OUTPUT:
  #
  # as a GreenTree:
  # "document" -> [
  #   "Fruits" -> ["Apples", "Pears"],
  #   "Vegetables" -> ["Green Beans"]
  # ]

  def convert_to_tree(headings)
    tree = GreenTree.new(nil, nil, 0, nil, self)
    convert_to_subtree(tree, headings.clone)
    tree.prepare_markup_indexes
    tree
  end

  # iterates over +headings+ and adds them as children of +parent_node+
  # until it reaches a heading that can't be a child
  def convert_to_subtree(parent_node, headings)
    # each element in oversection_headings is a list
    # this list contains all the headings (title and subsections) that make up a section
    until headings.empty?
      current_heading = headings.shift
      heading_level, text, name = *current_heading

      if parent_node.heading_level < heading_level
        # this is a child for the parent
        heading_node = parent_node.add_child(text, name, heading_level)
        convert_to_subtree(heading_node, headings)
      else
        # we're not seeing any more children for the parent_node
        # so whatever next heading might be, the higher node should deal with it
        # it could be a sibling of the current_heading
        # or it could be a sibling of the parent_node
        headings.unshift current_heading
        return
      end
    end
    # finished with all headings
  end

  # when there is a heading name collision, we must find a unique name for a heading
  def find_available_name(headings, original_name)
    i = 1
    name = original_name
    name = "#{original_name}_#{i += 1}" while headings[name]
    name
  end

  #  EXAMPLE TOC:
  #
  #  <ul class="toc">
  #    <li class="toc1"><a href="#fruits"><span>1</span> Fruits</a></li>
  #    <ul >
  #      <li class="toc2"><a href="#apples"><span>1.1</span> Apples</a></li>
  #      <ul >
  #        <li class="toc3"><a href="#green"><span>1.1.1</span> Green</a></li>
  #        <li class="toc3"><a href="#red"><span>1.1.2</span> Red</a></li>
  #      </ul>
  #      <li class="toc2"><a href="#pears"><span>1.2</span> Pears</a></li>
  #    </ul>
  #    <li class="toc1"><a href="#vegetables"><span>2</span> Vegetables</a></li>
  #    <ul >
  #      <li class="toc2"><a href="#turnips"><span>2.1</span> Turnips</a></li>
  #      <li class="toc2"><a href="#green-beans"><span>2.2</span> Green Beans</a></li>
  #    </ul>
  #  </ul>
  def generate_toc_html(tree, level, prefix = '')
    html = ["<ul#{level == 1 ? ' class="toc"' : ''}>"]
    tree.children.each_with_index do |node, i|
      number = [prefix, i + 1].join
      link = format('<a href="#%s"><span>%s</span> %s</a>', node.name, number, node.text)
      html << format('<li class="toc%i">%s</li>', level, link)
      html << generate_toc_html(node.children, level + 1, number + '.') unless node.leaf?
    end
    html << '</ul>'
    html.join("\n")
  end
end
