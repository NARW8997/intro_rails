class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @movies = Movie.all
    @all_ratings = Movie.all_ratings

    need_redirect = false
    if !params[:ratings].nil?
      @ratings_to_show = params[:ratings].keys
      @ratings_to_pass = params[:ratings]
      session[:ratings] = params[:ratings]
    elsif !session[:ratings].nil?
      @ratings_to_show = session[:ratings].keys
      @ratings_to_pass = session[:ratings]
      need_redirect = true
    else
      @ratings_to_show = Movie.all_ratings
      @ratings_to_pass = {'G':'1', 'PG':'1', 'PG-13':'1','R':'1'}
    end


    if !params[:filter_movies].nil?

      @current_select = params[:filter_movies]
      session[:filter_movies] = params[:filter_movies]
    elsif !session[:filter_movies].nil?
      @current_select = session[:filter_movies]
      need_redirect = true
    else
      @current_select = ''
    end

    if @current_select == 'movie_title'
      @movie_title_class = 'hilite bg-warning'
      @movie_release_date_class = ''
      @movies = Movie.with_ratings(@ratings_to_pass.keys).order(:title).distinct
    elsif @current_select == "release_date"
      @movie_title_class = ''
      @movie_release_date_class = 'hilite bg-warning'
      @movies = Movie.with_ratings(@ratings_to_pass.keys).order(:release_date).distinct
    else
      # @movie_title_class = ''
      # @movie_release_date_class = ''
      @movies = Movie.with_ratings(@ratings_to_show).distinct
    end

    if need_redirect
      redirect_to movies_path(:filter_movies => @current_select, :ratings => @ratings_to_pass)
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
