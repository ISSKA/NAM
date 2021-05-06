class DocumentsController < ApplicationController
  
	add_breadcrumb 'documents', :documents_path
	def index    
		@sort = params[:sort]
		if @sort == nil
			@documents = Document.all.order('created_at desc')
		else
			if @sort == 'name'
				@documents = Document.all.order('name desc')
			elsif @sort == 'file_type'
				@documents = Document.all.order('file_type desc')
			elsif @sort == 'purpose'
				@documents = Document.all.order('purpose desc')
			else
				@documents = Document.all.order('created_at desc')
			end
		end
	end   
      
	def new   
		@document = Document.new 
		@purpose = params[:purpose]
		@file_type = params[:file_type]
		@purpose_id = params[:id]
		if @purpose != nil
			@document[:purpose] = @purpose
			@document[:parent_id] = @purpose_id
			if @purpose == 'asset_mission'
				#@url_back = missions_path + "/#{params[:mission_id]}/asset_mission/#{params[:asset_id]}/edit"
			end
		end 
		if @file_type != nil
			@document[:file_type] = @file_type
		end 	  
	end   
      
	def create   
		@document = Document.new(document_params)   
		@purpose_id = @document.parent_id
		puts "document params = #{document_params}"
		@url
		@id = "nil"
		if @document.save   
			flash[:success] = "Successfully uploaded." 	
			@id = @document.id
			if @document.purpose == "asset_mission"
				@asset_mission = AssetMission.find(@purpose_id)
				@doc = ActiveRecord::Base.connection.exec_query("select images from asset_missions where id = #{@purpose_id}").rows[0][0]
				(@doc == nil || @doc == 'NULL')? (@doc = "#{@id};"): (@doc = "#{@doc}#{@id};")
				ActiveRecord::Base.connection.exec_query("update asset_missions set images = '#{@doc}' where id = #{@purpose_id}")
				@url = missions_path + "/#{@asset_mission.mission_id}/asset_mission/#{@asset_mission.id}/edit"
			end
			if @document.purpose == "mission"
				@mission = Mission.find(@purpose_id)
				@doc = ActiveRecord::Base.connection.exec_query("select documents from missions where id = #{@purpose_id}").rows[0][0]
				(@doc == nil || @doc == 'NULL')? (@doc = "#{@id};"): (@doc = "#{@doc}#{@id};")
				ActiveRecord::Base.connection.exec_query("update missions set documents = '#{@doc}' where id = #{@purpose_id}")
				@url = missions_path + "/#{@mission.id}/edit"
			end
			redirect_to @url + "?docId=#{@id}"
		else   
			flash[:danger] = "Problem with document."
			render 'new'
		end   
	end   
      
	def destroy   
		@document = Document.find(params[:id])   
		@purpose = params[:purpose]
		@purpose_id = params[:purpose_id]
		if @purpose == "asset_mission"
			@asset_mission = AssetMission.find(@purpose_id)
			@doc = ActiveRecord::Base.connection.exec_query("select images from asset_missions where id = #{@purpose_id}").rows[0][0]
			@doc = "#{@doc}"
			@doc["#{params[:id]};"] = ''
			if @doc == ''
				@doc = 'NULL'
			end
			ActiveRecord::Base.connection.exec_query("update asset_missions set images = '#{@doc}' where id = #{@purpose_id}")
			@document.destroy   
		end
		if @purpose == "mission"
			@mission = Mission.find(@purpose_id)
			@doc = ActiveRecord::Base.connection.exec_query("select documents from missions where id = #{@purpose_id}").rows[0][0]
			@doc = "#{@doc}"
			@doc["#{params[:id]};"] = ''
			if @doc == ''
				@doc = 'NULL'
			end
			ActiveRecord::Base.connection.exec_query("update missions set documents = '#{@doc}' where id = #{@purpose_id}")
			@document.destroy   
		end
		redirect_back(fallback_location: root_path)  
	end   
      
	private   
		def document_params   
		params.require(:document).permit(:name, :attachment, :file_type, :purpose, :parent_id)   
	end   
      
end  
