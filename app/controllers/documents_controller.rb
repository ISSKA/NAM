class DocumentsController < ApplicationController
  
   def index   
      @documents = Document.all   
   end   
      
   def new   
      @document = Document.new 
	  @purpose = params[:purpose]
	  @type = params[:type]
	  @purpose_id = params[:id]
	  if @purpose != nil
	    @document[:purpose] = @purpose
		@purpose_id = params[:id]
		if @purpose == 'asset_mission'
		  #@url_back = missions_path + "/#{params[:mission_id]}/asset_mission/#{params[:asset_id]}/edit"
		end
	  end 
      if @type != nil
	    @document[:type] = @type
	  end 	  
   end   
      
   def create   
      @document = Document.new(document_params)   
	  @purpose_id = params[:purpose_id]
	  puts "document params = #{document_params}"
	  @url
	  @id = "nil"
      if @document.save   
		 flash[:success] = "Successfully uploaded." 	
		 @id = @document.id
      else   
         flash[:danger] = "Problem with document."
      end   
	  if @document.purpose == "asset_mission"
	    @asset_mission = AssetMission.find(@purpose_id)
		if not @asset_mission.update(:img => @id)
		  flash[:danger] = "Problem with document."
		end
	    @url = missions_path + "/#{@asset_mission.mission_id}/asset_mission/#{@asset_mission.id}/edit"
	  end
	  redirect_to @url + "?docId=#{@id}"
   end   
      
   def destroy   
      @document = Document.find(params[:id])   
      @document.destroy   
      redirect_to documents_path, notice:  "Successfully deleted."   
   end   
      
   private   
      def document_params   
      params.require(:document).permit(:name, :attachment, :type, :purpose)   
   end   
      
end  
