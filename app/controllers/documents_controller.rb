class DocumentsController < ApplicationController
  
   def index   
      @documents = Document.all   
   end   
      
   def new   
      @document = Document.new 
	  @purpose = params[:purpose]
	  @type = params[:type]
	  if @purpose != nil
	    @document[:purpose] = @purpose
		if @purpose == 'asset_mission'
		  @url_back = missions_path + "/#{params[:mission_id]}/asset_mission/#{params[:asset_id]}/edit"
		end
	  end 
      if @type != nil
	    @document[:type] = @type
	  end 	  
   end   
      
   def create   
      @document = Document.new(document_params)   
      @url = params[:url]
      if @document.save   
         #redirect_to documents_path, notice: "Successfully uploaded." 
		 flash[:success] = "Successfully uploaded." 			 
      else   
         flash[:danger] = "Problem with document."
      end   
      #redirect_back(fallback_location: root_path)
	  redirect_to @url
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
