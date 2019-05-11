class BooksController < ApplicationController
  def index
    case params[:sort]
    when "rating-asc"
      @books = Book.all.sort_by(&:average_rating)
    when "rating-desc"
      @books = Book.all.sort_by(&:average_rating).reverse!
    else
      @books = Book.all
    end
  end

  def show
    if Book.pluck(:id).include?(params[:id].to_i)
      @book = Book.find(params[:id])
    else
      flash[:notice] = "There is no book with that ID"
      redirect_to books_path
    end
  end

  def new
    @book = Book.new
  end

  def create
    book = Book.new(
      year_published: book_params[:year_published],
      page_count: book_params[:page_count],
      thumbnail: book_params[:thumbnail].presence || 'https://nnp.wustl.edu/img/bookCovers/genericBookCover.jpg',
      title: book_params[:title].titlecase)
    if book.save
      author_names_input = book_params[:authors].split(",")

      author_names_input.each do |author_name|
        book.authors << Author.find_or_create_by(name: author_name.titlecase.strip)
      end

      redirect_to book_path(book)
    elsif !book.save && !Book.pluck.include?(book_params[:title])
      flash[:notice] = "This book has already been created."
      redirect_back(fallback_location: new_book_path)
    else
      flash[:notice] = "This new book could not be created."
      redirect_back(fallback_location: new_book_path)
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :year_published, :page_count, :thumbnail, :authors)
  end
end
