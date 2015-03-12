class MoodleUsersController < ApplicationController

  def index
    @path = params[:path]
    @categories = MoodleUser.all_categories

    if @path
      @students = MoodleUser.students_by_category(@path)
    else
      @students = MoodleUser.all
    end

  end
end
