# Mark translation content as html safe by default.

module ActionView
  module Helpers
    module TranslationHelper
      private

      def html_safe_translation_key?(_key)
        true
      end
    end
  end
end
