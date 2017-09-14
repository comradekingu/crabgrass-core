##
## CSS CACHE
##

module Crabgrass::Theme::Cache
  public

  def clear_cache(file = '')
    cached = css_destination_path(file)
    FileUtils.rm_r(cached, secure: true) if File.exist? cached
  end

  def updated_at
    config_updated_at.utc
  end

  def cache_key
    "theme/#{name}-#{updated_at.to_s(:number)}"
  end

  private

  #
  # returns true if any of the ruby files in the directory have been modified since
  # the timestamp given.
  #
  # def self.directory_changed_since?(dir, updated_at)
  #  Dir[dir + '/*.rb'].inject(100.years.ago) {|previous,current| [previous,File.mtime(current)].max} > updated_at
  # end

  #
  # returns true if any of the theme's config files have been modified since
  # the timestamp given.
  #
  def config_changed_since?(updated_at)
    config_updated_at > updated_at
  end

  def config_updated_at
    (all_data_paths + all_navigation_paths).inject(100.years.ago) do |previous, current|
      if current.nil?
        previous
      else
        [previous, File.mtime(current)].max
      end
    end
  end

  def clear_cache_if_needed(sheet_name)
    if Rails.env == 'development'
      updated_at = css_updated_at(sheet_name)
      if updated_at
        if config_changed_since?(updated_at)
          reload!
          clear_cache
        elsif sass_updated_at(sheet_name) > updated_at
          clear_cache(sheet_name)
        end
      end
    end
  end

  #
  # used to determine if the theme's css files need to be regenerated.
  #
  def sass_updated_at(sheet_name)
    if sheet_name == 'screen'
      newest = File.mtime(sass_source_path('screen'))
      sass_files_for_screen.each do |sass_file|
        newest = [File.mtime(sass_file), newest].max
      end
      newest
    else
      File.mtime(sass_source_path(sheet_name))
    end
  end

  def css_updated_at(sheet_name)
    path = css_destination_path(sheet_name)
    File.exist?(path) ? File.mtime(path) : nil
  end

  def sass_files_for_screen
    # grab everything. not sure what might be in screen.
    Dir.glob(
      ['*.sass', '*.scss', '*/*.sass', '*/*.scss'].collect do |dir|
        Crabgrass::Theme::SASS_ROOT + dir
      end
    )
  end
end
