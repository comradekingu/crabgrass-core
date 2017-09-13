#
# Last Visit Helper
#
# last_visit will return the last time the current user visited a page or group
#
# This can be used to highlight changes that happened later.
#
module Common::Utility::LastVisitHelper
  def last_visit
    # either the last timestamp or now so we do not mark anything as new
    context = @page || @group
    if context
      context.last_visit_of(current_user) || Time.now
    else
      Time.now
    end
  end
end
