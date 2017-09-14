class Wiki::Structure
  # this is used for aggregation, not for inclusion in Wiki model
  attr_reader :green_tree

  def initialize(raw_structure, body)
    @green_tree = GreenTree.from_hash(raw_structure, body)
  end

  # all parent and child elements for section
  def genealogy_for_section(section)
    names = find(section).genealogy.collect &:name
    names.compact.unshift :document
  end

  def all_sections
    [:document] + green_tree.section_names
  end

  def sections
    green_tree.section_names
  end

  def update_body(section, section_body)
    find(section).sub_markup(section_body)
  end

  def get_body(section)
    find(section).markup
  end

  def get_level(section)
    find(section).heading_level
  end

  def get_successor(section)
    find(section).successor
  end

  def find_section(name)
    find(name)
  end

  protected

  def find(section)
    node = green_tree if section == :document
    node ||= green_tree.find(section)
    node || (raise Wiki::Sections::SectionNotFoundError.new(section))
  end
end
