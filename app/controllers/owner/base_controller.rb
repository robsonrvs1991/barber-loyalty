module Owner
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_owner
  end
end
