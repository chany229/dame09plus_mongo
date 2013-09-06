# encoding: utf-8
class HomeController < ApplicationController
	before_filter :authenticate_user!, :except => [:index]
	layout false

	def index
	end

	def frame
		render :layout => "yamato_raven"
	end

	def top
	end

	def logs
		@entries = Entry.desc(:created_at).page(params[:page] || 1).per(5)
		@filter  = "全部"
		respond_to do |format|
			format.html {
				@tags = Entry.all_tags
				@calendar_date = @entries.first.created_at
				@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
			}
			format.js {
				if @should_load_log = params[:should_load_log] || false
					@tags = Entry.all_tags
					@calendar_date = @entries.first.created_at
					@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
				end
				render 'search.js.erb'
			}
		end
	end

	def tag
		tag      = params[:tag_name]
		@entries = Entry.tagged_with(tag).desc(:created_at).page(params[:page] || 1).per(5)
		@filter  = "标签[#{tag}]"
		respond_to do |format|
			format.html {
				@calendar_date = Time.now
				@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
				@tags = Entry.all_tags
				render :action => :logs
			}
			format.js {
				if @should_load_log = params[:should_load_log] || false
					@calendar_date = Time.now
					@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
					@tags = Entry.all_tags
				end
				render 'search.js.erb'
			}
		end
	end

	def keyword
		keyword  = params[:keyword]
		@entries = Entry.where(["body like ?", "%#{keyword}%"]).order("created_at desc").paginate(:page => @page, :per_page => per_page)
		@filter  = "关键词[#{keyword}]"
		respond_to do |format|
			format.html {
				@date = Time.now
				@tags = Entry.tag_counts_on(:tags).order('count desc')
				render :action => :logs
			}
			format.js {
				if @should_load_log = params[:should_load_log] || false
					@date = Time.now
					@tags = Entry.tag_counts_on(:tags).order('count desc')
				end
				render 'search.js.erb'
			}
		end
	end

	def date
		now      = Time.now
		@year    = params[:year]  || now.year
		@month   = params[:month] || now.month
		@day     = params[:day]   || now.day
		if params[:day]
			start_time = Time.new(@year,@month,@day).beginning_of_day
			end_time = Time.new(@year,@month,@day).end_of_day
			@filter = "#{@year}年#{@month}月#{@day}日"
		elsif params[:month]
			start_time = Time.new(@year,@month,1).beginning_of_month
			end_time = Time.new(@year,@month,1).end_of_month
			@filter = "#{@year}年#{@month}月"
		elsif params[:year]
			start_time = Time.new(@year,1,1).beginning_of_year
			end_time = Time.new(@year,1,1).end_of_year
			@filter = "#{@year}年"
		else
			redirect_to '#/logs'
			return
		end
		@entries = Entry.where(:created_at => start_time..end_time).desc(:created_at).page(params[:page] || 1).per(5)
		respond_to do |format|
			format.html {
				@calendar_date = Time.now
				@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
				@tags = Entry.all_tags
				render :action => :logs
			}
			format.js {
				if @should_load_log = params[:should_load_log] || false
					@calendar_date = Time.now
					@calendar_events = Entry.where(:created_at => @calendar_date.beginning_of_month..@calendar_date).map{ |e| e.created_at.day }.uniq
					@tags = Entry.all_tags
				end
				render 'search.js.erb'
			}
		end
	end
	def calendar
		@date = Time.at(params[:date].to_i)
		@events = Entry.where(:created_at => @date.beginning_of_month..@date.end_of_month).map{ |e| e.created_at.day }.uniq
		respond_to do |format|
			format.js
		end
	end
end
