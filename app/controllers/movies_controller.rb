class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort = params[:sort]
    # @movies = Movie.order(params[:sort])
    # @movies = @movies.where(:rating => params[:ratings].keys) if params[:ratings].present?
    session.delete(:sorting_user)
    @all_ratings = Movie.distinct.pluck(:rating)
    @movies = Movie.all

    unless params[:ratings].nil?
      @selected_ratings = params[:ratings]
      session[:selected_ratings] = @selected_ratings
    end

    if params[:sorting_user].nil?
      #
    else
      session[:sorting_user] = params[:sorting_user]
    end

    if params[:sorting_user].nil? && params[:ratings].nil? && session[:selected_ratings]
      @selected_ratings = session[:selected_ratings]
      @sorting_user = session[:sorting_user]
      flash.keep
      redirect_to movies_path({order_by: @sorting_user, ratings: @selected_ratings})
    end

    if session[:selected_ratings]
      @movies = @movies.select{ |movie| session[:selected_ratings].include? movie.rating }
    end

    if session[:sorting_user] == "title"
      @movies = @movies.sort { |a,b| a.title <=> b.title }
      @movie_column_class = "hilite"
    elsif session[:sorting_user] == "release_date"
      @movies = @movies.sort { |a,b| a.release_date <=> b.release_date }
      @date_column_class = "hilite"
    end

   
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
