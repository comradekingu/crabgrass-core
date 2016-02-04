source 'https://rubygems.org'


##
#  Core components
##

# Rails is the framework we use.
# use the 3.2 series including all security fixes
gem 'rails', '~> 4.0.13'

# Rake is rubys make... performing tasks
# locking in to latest major to fix API
gem 'rake', '~> 10.0', require: false

# Bcrypt for has_secure_password
gem 'bcrypt', '~> 3.1.7'

##
# Prototype - yes. we still use it.
# these will be replaced by jquery equivalents at some point:
##

# main part of prototype
# locking so it matches rails version
gem 'prototype-rails', '~> 4.0.1'

# legacy helper for form_remote_for and link_to_remote
# there's only a 0.0.0 version out there it seems
gem 'prototype_legacy_helper', '0.0.0',
  github: 'rails/prototype_legacy_helper'

##
# Upgrade pending
##

# Full text search for the database
# thinking-sphinx version 3.1.4 has dropped support for some features
# with rails 3.2 but they should not affect us
# 3.1.3 prints warnings with latest sphinx:
# https://github.com/pat/thinking-sphinx/issues/882
gem 'thinking-sphinx', '3.1.4', require: 'thinking_sphinx'

#
# Use delayed job to postpone the delta processing
# latest version available. Stick to major release
gem 'ts-delayed-delta', '~> 2.0'

# Enhanced Tagging lib. Used to tag pages
# Could not get the migration rake task for acts-as-taggable-on 3.x to work
# before rails 3.2.
# So we should run the migration and upgrade now that we are on rails 3.2
gem 'acts-as-taggable-on', '~> 2.4.1'

# Page Caching has been removed from rails 4.
# migrate it and drop this.
gem 'actionpack-page_caching'

##
#  Required, but not included with crabgrass:
##

# translating strings for the user interface
# locking in to latest major to fix API
gem 'i18n', '~> 0.7'

# improved gem to access mysql database
# locking in to latest major to fix API
gem 'mysql2', '~> 0.3.18'

# parsing and generating JSON
# locking in to latest major to fix API
gem 'json', '~> 1.8'

# Markup language that uses indent to indicate nesting
# locking in to latest major to fix API
gem 'haml', '~> 4.0'
gem 'haml-rails', '~> 0.9.0'

# Extendet scriptable CSS language
# locking in to latest major to fix API
gem 'sass'

# ?
# locking in to latest major to fix API
gem 'http_accept_language', '~> 2.0'

# Removes invalid UTF-8 characters from requests
# use the latest. No API that could change.
gem 'utf8-cleaner'

# Pagination for lists with a lot of items
# 3.0.7 introduced a bug: https://github.com/mislav/will_paginate/issues/400
# we should remove this strict version once that is fixed.
gem 'will_paginate', '= 3.0.6'

# state-machine for requests
# locking in to latest major to fix API
gem 'aasm' , '~> 3.4'

# lists used for tasks and choices in votes so far
# continuation of the old standart rails plugin
# locking in to latest major to fix API, not really maintained though
gem 'acts_as_list', '~> 0.4'

# Check the format of email addresses against RFCs
# better maintained than validates_as_email
# locking in to latest major to fix API
gem 'validates_email_format_of', '~> 1.6'

##
## GEMS required, and compilation is required to install
##

# Formatting text input
# We extend this to resolve links locally -> GreenCloth
# locking in to latest major to fix API
gem 'RedCloth', '~> 4.2'

# HTML parser used inside our own uglify gem
# Deprecated by the original maintainers
# TODO: replace with nokogiri
gem 'hpricot', '~> 0.8'

##
## GEMS required, included with crabgrass
##

# extension of the redcloth markup lang
gem 'greencloth', require: 'greencloth',
  path: 'vendor/gems/riseuplabs-greencloth-0.1'

# ?
gem 'undress', require: 'undress/greencloth',
  path: 'vendor/gems/riseuplabs-undress-0.2.4'

# ?
gem 'uglify_html', require: 'uglify_html',
  path: 'vendor/gems/riseuplabs-uglify_html-0.12'

# media upload post processing has it's own repo
# version is rather strict for now as api may still change.
gem 'crabgrass_media', '~> 0.1.1', require: 'media'

##
## GEMS not required, but a really good idea
##

# detect mime-types of uploaded files
#
gem 'mime-types', require: 'mime/types'

# process heavy tasks asynchronously
# 4.0 is most recent right now. fix major version.
gem 'delayed_job_active_record', '~> 4.0'

# delayed job runner as a deamon
gem 'daemons'

# unpack file uploads
# TODO: why is this locked to 1.1. ?
gem 'rubyzip', '~> 1.1.0', require: false

# load new rubyzip, but with the old API.
# TODO: use the new zip api and remove gem zip-zip
gem 'zip-zip', require: 'zip'

group :production do
  # js runtime needed to precompile assets
  # runs independendly - so no version restriction for now
  # TODO: check if we want this or nodejs
  gem 'therubyracer'
end

group :production, :development do
  # used to install crontab
  gem 'whenever', require: false
  # used to minify javascript
  # I don't think this is used in production with the Asset Pipeline
  # TODO check if it's needed at all
  gem 'jsmin', require: false
end

group :development do
  ##
  ## needed for some rake tasks, but not generally.
  ##
  gem 'rdoc', '~> 3.0'
end

group :test, :development do
  gem 'byebug'
end

group :test, :ci do

  ##
  ## GEMS REQUIRED FOR TESTS
  ##

  gem 'factory_girl_rails'
  gem 'faker', '~> 1.0.0'

  # 4.2 is required by rails 4.0.13
  gem 'minitest', '~> 4.7', require: false
  gem 'mocha', '~> 1.1', require: false
  #
  # mocha note: mocha must be loaded after the things it needs to patch.
  #             so, we skip the 'require' here, and do it later.
  #             also, requiring either mocha or minitest here causes zeus to
  #             run tests twice, if using zeus (which you should).
  #

  ##
  ## GEMS REQUIRED FOR INTEGRATION TESTS
  ##

  gem 'capybara', require: false

  # Capybara driver with javascript capabilities using phantomjs
  # locked to major version for stable API
  gem 'poltergeist', '~> 1.5', require: false

  # Headless webkit browser for testing, fast and with javascript
  # Version newer than 1.8 is required by current poltergeist.
  gem 'phantomjs-binaries', '~> 1.8', require: false

  # The castle_gates tests are based on sqlite
  gem 'sqlite3'
end
