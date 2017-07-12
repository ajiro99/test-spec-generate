class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :export]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      @project.touch
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def export
    #@scenarios = Scenario.where(@project.id).order(:scenario_no, :updated_at)
    @scenarios = Scenario.where(project_id: params[:id])

    puts @scenarios
    respond_to do |format|
      format.xlsx do
        generate_xlsx
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:project_name, :description)
    end
    
    def generate_xlsx
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: "シナリオ一覧") do |sheet|   
          styles = p.workbook.styles

          table_cell = styles.add_style border: { style: :thin, color: '00' }, 
                                               alignment: { horizontal: :left, vertical: :top, wrap_text: :true }
                                               
          header_cell = styles.add_style border: { style: :thin, color: '00' }, 
                                               alignment: { horizontal: :left, vertical: :top, wrap_text: :true }, 
                                               bg_color: 'E6E6FA'

          sheet.column_widths(15, 40, 40, 11, 11, 11, 11, 11)
          sheet.add_row(['プロジェクト名', @project.project_name], style: header_cell) 
          sheet.add_row()
          
          sheet.add_row(['No.','シナリオ名','概要','総項目数','対象項目数','残項目数','OK数','NG数'], style: header_cell)     

          @scenarios.each do |scenario|
            sheet.add_row([scenario.scenario_no, scenario.scenario_name, scenario.description, 
              scenario.count_item, scenario.count_item_target, scenario.count_remaining, scenario.count_ok, scenario.count_ng], style: table_cell)
          end
        end
      
        @scenarios.each do |scenario|
          p.workbook.add_worksheet(name: "#{scenario.scenario_no}") do |sheet|   
            styles = p.workbook.styles
            table_cell = styles.add_style border: { style: :thin, color: '00' }, 
                                                 alignment: { horizontal: :left, vertical: :top, wrap_text: :true }

            header_cell = styles.add_style border: { style: :thin, color: '00' }, 
                                                 alignment: { horizontal: :left, vertical: :top, wrap_text: :true }, 
                                               bg_color: 'E6E6FA'
            
            sheet.column_widths(12, 40, 40, 40, 11, 11, 11, 11)                         
            sheet.add_row(['シナリオNo.','シナリオ名','概要','総項目数','対象項目数','残項目数','OK数','NG数'], style: header_cell)  
            sheet.add_row([scenario.scenario_no, scenario.scenario_name, scenario.description, 
                scenario.count_item, scenario.count_item_target, scenario.count_remaining, scenario.count_ok, scenario.count_ng], style: table_cell)
            
            sheet.add_row([''])
            @test_cases = scenario.test_cases
            
            sheet.add_row(['No.','画面名','テスト内容','確認内容','ステータス'], style: header_cell)
            @test_cases.each do |test_case|
              status = ""
              case test_case.status
              when "1"
                status = "OK"
              when "2"
                status = "NG"
              when "3"
                status = "NG→OK"
              when "4"
                status = "-"
              end
              
              sheet.add_row([test_case.test_case_no, test_case.screen_name, test_case.test_content, 
                test_case.check_content, status], style: table_cell)
            end
            
          end
        end  
        
        file_name = "#{@project.project_name}.xlsx"
        file_name = ERB::Util.url_encode(file_name)
        
        send_data(p.to_stream.read,
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                filename: file_name)
      end
    end
  end
