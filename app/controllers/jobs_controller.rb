class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :validates_search_key, only: [:search]
  def index
    @jobs = case params[:order]
    when 'by_lower_bound'
      Job.published.order('wage_lower_bound DESC')
    when 'by_upper_bound'
      Job.published.order('wage_upper_bound DESC')
    else
      Job.published.recent
    end
  end
  def show
    @job = Job.find(params[:id])
    if @job.is_hidden
      flash[:warning] = "This Job already archieved"
      redirect_to root_path
    end
  end
  def new
    @job = Job.new
  end
  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to jobs_path
    else
      render :new
    end
  end
  def edit
    @job = Job.find(params[:id])
  end
  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      redirect_to jobs_path
    else
      render :edit
    end
  end
  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to jobs_path
  end
  def search
    if @query_string.present?
      @jobs = search_params
    end
  end
  protected
  def validates_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
  end
  private
  def job_params
    params.require(:job).permit(:title, :description, :wage_lower_bound, :wage_upper_bound, :contact_email, :is_hidden )
  end
  def search_params
    case params[:order]
    when "wage_upper_bound"
      Job.ransack({title_or_description_cont: @query_string}).result(distinct: true).published.order("wage_upper_bound DESC")
    when "wage_lower_bound"
      Job.ransack({title_or_description_cont: @query_string}).result(distinct: true).published.order("wage_lower_bound DESC")
    else
      Job.ransack({title_or_description_cont: @query_string}).result(distinct: true).published
    end
  end
end
