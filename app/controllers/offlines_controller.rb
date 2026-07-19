class OfflinesController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    render layout: "application_no_sidebar"
  end
end
