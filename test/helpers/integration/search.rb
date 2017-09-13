#
# Thinking Sphinx usually does not index pages during tests.
# In order to test Sphinx search properly include this module.
#
module Integration
  module Search
    SPHINX_ENABLED_SETTINGS = {
      attribute_updates: true,
      quiet_deltas: true
    }.freeze

    def setup
      super
      @_ts_old_settings = sphinx_settings.dup
      sphinx_settings.merge! SPHINX_ENABLED_SETTINGS
    end

    def teardown
      if @_ts_old_settings.present?
        overwritten = @_ts_old_settings.slice(SPHINX_ENABLED_SETTINGS.keys)
        sphinx_settings.merge! overwritten
      end
      super
    end

    def sphinx_config
      ThinkingSphinx::Configuration.instance
    end

    def sphinx_settings
      sphinx_config.settings
    end
  end
end
