
##
## levels of page access
##

ACCESS = HashWithIndifferentAccess.new(admin: 1, edit: 2, view: 3, none: nil).freeze
ACCESS_TO_SYM = { 1 => :admin, 2 => :edit, 3 => :view }.freeze

ACCESS_ADMIN = 1
ACCESS_EDIT = 2
ACCESS_VIEW = 3

##
## types of page flows
##

FLOW = { normal: 0, deleted: 3, announcement: 5 }.freeze

##
## enum of media types
##

MEDIA_TYPE = {
  image: 1,
  audio: 2,
  video: 3,
  document: 4
}.freeze

##
## enum of actions for tracking
##

ACTION = {
  view: 1,
  edit: 2,
  star: 3,
  unstar: 4,
  comment: 5, # not used yet
  share: 6 # not used yet
}.freeze

##
## HTML Entity Constants
##

ARROW = ' &raquo; '.freeze
BULLET = ' &bull; '.freeze
RARROW = ' &raquo; '.freeze
LARROW = ' &laquo; '.freeze

##
## a time to use when displaying recent records
##

RECENT_TIME = 1.weeks

##
## caching constants
##

CACHING_ENTITIES_IN_HOURS = 3

##
## asset constants
##

THUMBNAIL_SEPARATOR = '_'.freeze
