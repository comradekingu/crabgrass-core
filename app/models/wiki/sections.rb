module Wiki::Sections
  class SectionNotFoundError < CrabgrassException
    def initialize(section = 'document', _options = {})
      message = :cant_find_wiki_section.t(section: section)
      super(message)
    end
  end

  def all_sections
    structure.all_sections
  end

  def save_section!(section, text)
    section = structure.find_section(section) unless section.is_a? GreenTree
    updated_body = section.sub_markup(text)
    return if body == updated_body
    self.body = updated_body
    save!
  end

  def get_body_for_section(section)
    structure.get_body(section)
  end

  def level_for_section(section)
    structure.get_level(section)
  end

  def successor_for_section(section)
    structure.get_successor(section)
  end

  def get_body_html_for_section(section)
    GreenCloth.new(get_body_for_section(section), link_context, [:outline]).to_html
  end
end
