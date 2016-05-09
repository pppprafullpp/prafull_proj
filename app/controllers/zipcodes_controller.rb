class ZipcodesController < ApplicationController
  before_action :set_zipcode, only: [:show, :edit, :update, :destroy]

  # GET /zipcodes
  # GET /zipcodes.json
  # def index
  #   @zipcodes = Zipcode.all
  # end

  def index
    @zipcodes = Zipcode.all
    respond_to do |format|
      format.html
      #format.xls # { send_data @products.to_csv(col_sep: "\t") }
      format.csv {
        csv_string = CSV.generate do |csv|
          # header row
          csv << 
          [ "id",              
            "code",             
            "area",  
            "city",  
            "state",  
            "country",  
            "created_at",
            "updated_at",           
          ]  

          # data rows
          @zipcodes.each do |zp|
            csv << 
            [ zp.id,              
              zp.code,
              zp.area,
              zp.city,
              zp.state,
              zp.country,
              zp.created_at,
              zp.updated_at
            ]
          end               
        end 
        # send it to the browser
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=zipcodes.csv" 
      }
    end
  end

  # GET /zipcodes/1
  # GET /zipcodes/1.json
  def show
  end

  # GET /zipcodes/new
  def new
    @zipcode = Zipcode.new
  end

  # GET /zipcodes/1/edit
  def edit
  end

  # POST /zipcodes
  # POST /zipcodes.json
  def create
    @zipcode = Zipcode.new(zipcode_params)

    respond_to do |format|
      if @zipcode.save
        format.html { redirect_to @zipcode, notice: 'Zipcode was successfully created.' }
        format.json { render :show, status: :created, location: @zipcode }
      else
        format.html { render :new }
        format.json { render json: @zipcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /zipcodes/1
  # PATCH/PUT /zipcodes/1.json
  def update
    respond_to do |format|
      if @zipcode.update(zipcode_params)
        format.html { redirect_to @zipcode, notice: 'Zipcode was successfully updated.' }
        format.json { render :show, status: :ok, location: @zipcode }
      else
        format.html { render :edit }
        format.json { render json: @zipcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zipcodes/1
  # DELETE /zipcodes/1.json
  def destroy
    @zipcode.destroy
    respond_to do |format|
      format.html { redirect_to zipcodes_url, notice: 'Zipcode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    Zipcode.import(params[:file])
    redirect_to zipcodes_path, notice: "Successfully imported."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zipcode
      @zipcode = Zipcode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zipcode_params
      params.require(:zipcode).permit!
    end
end
